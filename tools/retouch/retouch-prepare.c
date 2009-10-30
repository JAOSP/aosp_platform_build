#include <stdio.h>
#include <stdlib.h>
#include <libelf.h>
#include <libebl.h>
#ifdef ARM_SPECIFIC_HACKS
#include <libebl_arm.h>
#endif /*ARM_SPECIFIC_HACKS*/
#include <elf.h>
#include <gelf.h>
#include <string.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <libgen.h>

#define MAX_FULL_NAME 1024

#define FAILIF(cond, msg...) do { \
    if (cond) {                   \
      fprintf(stderr, ##msg);     \
      exit(1);                    \
    }                             \
  } while(0)

int is_host_little(void) {
  short val = 0x10; return ((char *)&val)[0] != 0;
}

int32_t switch_endianness(int32_t val)
{
  int32_t newval;
  ((char *)&newval)[3] = ((char *)&val)[0];
  ((char *)&newval)[2] = ((char *)&val)[1];
  ((char *)&newval)[1] = ((char *)&val)[2];
  ((char *)&newval)[0] = ((char *)&val)[3];
  return newval;
}

typedef struct {
	int32_t mmap_addr;
	char tag[4]; /* 'P', 'R', 'E', ' ' */
} prelink_info_t __attribute__((packed));

int check_prelinked(int fd) {
  FAILIF(sizeof(prelink_info_t) != 8, 
	 "Unexpected sizeof(prelink_info_t) == %d!\n", 
	 sizeof(prelink_info_t));
  off_t end = lseek(fd, 0, SEEK_END);  
  int nr = sizeof(prelink_info_t);
  off_t sz = lseek(fd, -nr, SEEK_CUR);
  FAILIF((long)(end - sz) != (long)nr,
	 "Bad offset after lseek\n");
  FAILIF(sz == (off_t)-1, 
	 "lseek(%d, 0, SEEK_END): %s (%d)!\n", 
	 fd, strerror(errno), errno);
  
  prelink_info_t info;
  int num_read = read(fd, &info, nr);
  FAILIF(num_read < 0, 
	 "read(%d, &info, sizeof(prelink_info_t)): %s (%d)!\n",
	 fd, strerror(errno), errno);
  FAILIF(num_read != sizeof(info),
	 "read(%d, &info, sizeof(prelink_info_t)): did not read %d bytes as "
	 "expected (read %d)!\n",
	 fd, sizeof(info), num_read);
  
  int prelinked = 0;
  if (!strncmp(info.tag, "PRE ", 4)) {
    prelinked = 1;
  }
  return prelinked;
}

void output_prelink_info(FILE *f_out, 
			 int fd_lib, int elf_little) {
  int nr = sizeof(prelink_info_t);
  FAILIF(nr != 8, "Unexpected sizeof(prelink_info_t) == %d!\n", nr);

  off_t end = lseek(fd_lib, 0, SEEK_END);  
  off_t sz = lseek(fd_lib, -nr, SEEK_CUR);
  FAILIF((long)(end - sz) != (long)nr,
	 "Bad offset after lseek\n");
  FAILIF(sz == (off_t)-1, 
	 "lseek(%d, 0, SEEK_END): %s (%d)!\n", 
	 fd_lib, strerror(errno), errno);
  
  prelink_info_t info;
  int num_read = read(fd_lib, &info, nr);
  FAILIF(num_read < 0, 
	 "read(%d, &info, sizeof(prelink_info_t)): %s (%d)!\n",
	 fd_lib, strerror(errno), errno);
  FAILIF(num_read != sizeof(info),
	 "read(%d, &info, sizeof(prelink_info_t)): did not read %d bytes as "
	 "expected (read %d)!\n",
	 fd_lib, sizeof(info), num_read);

  if (!(elf_little ^ is_host_little())) {
    /* Same endianness */
    fprintf(f_out, "-1 %lu\n", info.mmap_addr);
  } else {
    /* Different endianness */
    fprintf(f_out, "-1 %lu\n", switch_endianness(info.mmap_addr));
  }
}

void output_relocation(FILE *f_out, 
		       int fd_lib, int elf_little, 
		       int32_t offset) {
  uint32_t retouch_contents;

  FAILIF(lseek(fd_lib, offset, SEEK_SET) != offset,
	 "Could not seek for reading!\n");
  FAILIF(read(fd_lib, &retouch_contents, 4) != 4,
         "Could not read retouch bytes!\n");
  fprintf(f_out, "%ld %lu\n", offset, 
	  (!(elf_little ^ is_host_little()))?
	  retouch_contents:
	  switch_endianness(retouch_contents));
}

int main(int argc, char **argv) {
  int fd_elf_ro = -1;
  uint32_t shstrndx;
  FILE *file_apriori = NULL, *file_retouch = NULL;
  char current_lib_full_name[MAX_FULL_NAME];
  size_t shnum;
  Elf *e = NULL;
  Elf_Kind ek;
  GElf_Ehdr ehdr;
  uint64_t line_count;

  uint64_t retouch_offset;
  char retouch_libname[MAX_FULL_NAME];
  char retouch_sname[MAX_FULL_NAME];

  FAILIF(argc != 4,
	 "Usage: %s <apriori-relo-file> "
	 "<library-file> <retouch-file>\n", 
	 argv[0]);
  FAILIF(elf_version(EV_CURRENT) == EV_NONE,
	 "ELF library initialization failed: %s\n",
	 elf_errmsg(-1));

  // open the library (object) itself
  FAILIF((fd_elf_ro = open(argv[2], O_RDONLY, 0)) < 0,
	 "open(\"%s\") failed\n", 
	 argv[2]);
  FAILIF((e = elf_begin(fd_elf_ro, ELF_C_READ, NULL)) == NULL,
	 "elf_begin() failed: %s\n", 
	 elf_errmsg(-1));
  ek = elf_kind(e);
  FAILIF(ek != ELF_K_ELF,
	 "Unhandled object type.\n");

  // ELF header
  FAILIF(gelf_getehdr(e, &ehdr) == NULL,
	 "getehdr() failed: %s\n", 
	 elf_errmsg(-1));
  FAILIF(gelf_getclass(e) == ELFCLASSNONE,
	 "getclass() failed: %s\n", 
	 elf_errmsg(-1));
  // section name strings 
  FAILIF(elf_getshstrndx(e, &shstrndx) < 0,
	 "getshstrndx() failed: %s\n", 
	 elf_errmsg(-1));
  // section count
  FAILIF(elf_getshnum(e, &shnum) < 0,
	 "getshnum() failed: %s", 
	 elf_errmsg(-1));

  if (!check_prelinked(fd_elf_ro)) {
    printf("File %s is not prelinked; skipping\n", argv[2]);
    goto out;
  }

  // open the relocation list for retouching, and the output file
  FAILIF((file_apriori = fopen(argv[1], "r")) == NULL,  
	 "Could not fopen(\"%s\")\n", 
	 argv[1]);
  FAILIF((file_retouch = fopen(argv[3], "w")) == NULL,  
	 "Could not fopen(\"%s\")\n", 
	 argv[3]);

  // loop over all touch-up entries
  line_count = 0;
  current_lib_full_name[0] = 0;
  while (!feof(file_apriori)) {
    char one_line[MAX_FULL_NAME];

    // read one touch-up entry
    one_line[0]=0;
    fgets(one_line, MAX_FULL_NAME, file_apriori);
    if (sscanf(one_line,
	       "%s %s %llu",
	       retouch_libname,
	       retouch_sname,
	       &retouch_offset) != 3) {
      printf("Retouch complete (%llu entries processed).\n", line_count);
      break;
    }
    line_count++;

    // find the section and fix at the specified offset
    uint32_t sectIx;
    for (sectIx=0; sectIx<shnum; sectIx++) {
      Elf_Scn *scn;
      GElf_Shdr shdr;
      char *elf_sname;
      
      FAILIF((scn = elf_getscn(e, sectIx)) == NULL,
	     "getscn() failed: %s\n", 
	     elf_errmsg(-1));
      FAILIF(gelf_getshdr(scn, &shdr) != &shdr,
	     "getshdr() failed: %s\n", 
	     elf_errmsg(-1));
      FAILIF((elf_sname = elf_strptr(e, shstrndx, shdr.sh_name)) == NULL,
	     "elf_strptr() failed: %s\n", 
	     elf_errmsg(-1));
      if (strcmp(elf_sname, retouch_sname) == 0) {
	// found the section: check size for sanity
	if (shdr.sh_size < retouch_offset) {
	  printf("Retouch offset %llu is greater than the section size %llu\n",
		 retouch_offset, shdr.sh_size);
	}

	// fix contents, and we are done
	uint64_t file_offset = shdr.sh_offset + retouch_offset;
	output_relocation(file_retouch, 
			  fd_elf_ro, ehdr.e_ident[EI_DATA] == ELFDATA2LSB, 
			  file_offset);
	break;
      }
    }
    FAILIF(sectIx >= shnum,
	   "Could not find section: %s\n", 
	   retouch_sname);
  }

  // now fix the "PRE "+offset at the end of the library
  output_prelink_info(file_retouch,
		      fd_elf_ro, 
  		      ehdr.e_ident[EI_DATA] == ELFDATA2LSB);

 out:
  // clean up
  if (e) elf_end(e);
  if (fd_elf_ro >= 0) close(fd_elf_ro);
  if (file_apriori) fclose(file_apriori);
  if (file_retouch) fclose(file_retouch);

  return 0;
}
