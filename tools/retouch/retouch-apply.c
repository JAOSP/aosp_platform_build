#include <stdio.h>
#include <stdlib.h>
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

void set_prelink_info(int fd, int value) {
  int nr = sizeof(prelink_info_t);
  FAILIF(nr != 8, "Unexpected sizeof(prelink_info_t) == %d!\n", nr);

  off_t end = lseek(fd, 0, SEEK_END);  
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

  info.mmap_addr = value;
  strncpy(info.tag, "PRE ", 4);
  
  end = lseek(fd, 0, SEEK_END);  
  sz = lseek(fd, -nr, SEEK_CUR);
  FAILIF((long)(end - sz) != (long)nr,
	 "Bad offset after lseek\n");
  FAILIF(sz == (off_t)-1, 
	 "lseek(%d, 0, SEEK_END): %s (%d)!\n", 
	 fd, strerror(errno), errno);

  int num_written = write(fd, &info, sizeof(info));
  FAILIF(num_written < 0, 
	 "write(%d, &info, sizeof(info)): %s (%d)\n",
	 fd, strerror(errno), errno);
  FAILIF(sizeof(info) != num_written, 
	 "Could not write %d bytes (wrote only %d bytes) as expected!\n",
	 sizeof(info), num_written);
}

// Note we are working with 32-bit numbers explicitly. This should
// change at some point.
void set_relocation(int fd, int64_t offset, uint32_t value) {
  FAILIF(lseek(fd, offset, SEEK_SET) != offset,
         "Could not seek for writing!\n");
  FAILIF(write(fd, &value, 4) != 4,
	 "Could not write during retouch!\n");
}

int main(int argc, char **argv) {
  int fd_elf_rw = -1;
  FILE *file_retouch = NULL;
  uint32_t line_count;
  
  uint32_t random_offset;
  int argIx;
  int32_t retouch_offset;
  uint32_t retouch_original_value;

  char retouch_filename[MAX_FULL_NAME];

  FAILIF(argc < 2,
	 "Usage: %s [-u] <library-file1> ... <library-fileN>\n",
	 argv[0]);

  if (strcmp(argv[1], "-u")) {
    random_offset = 0;
    argIx = 2;
  } else {
    random_offset = 0x2000;
    argIx = 1;
  }

  while (argIx < argc) {
    // open the library
    FAILIF((fd_elf_rw = open(argv[argIx], O_RDWR, 0)) < 0,
	   "open(\"%s\") failed\n", 
	   argv[argIx]);

    if (!check_prelinked(fd_elf_rw)) {
      printf("File %s is not prelinked; skipping\n", argv[argIx]);
      goto out;
    }

    // open the retouch list (associated with this library)
    snprintf(retouch_filename, MAX_FULL_NAME,
	     "%s.retouch", argv[argIx]);
    FAILIF((file_retouch = fopen(retouch_filename, "r")) == NULL,  
	   "Could not fopen(\"%s\")\n", 
	   retouch_filename);

    // loop over all retouch entries
    line_count = 0;
    while (!feof(file_retouch)) {
      char one_line[MAX_FULL_NAME];
      
      // read one retouch entry
      one_line[0]=0;
      fgets(one_line, MAX_FULL_NAME, file_retouch);
      if (sscanf(one_line,
		 "%d %u",
		 &retouch_offset,
		 &retouch_original_value) != 2) {
	// printf("Retouch complete (%u entries processed).\n", line_count);
	break;
      }
      line_count++;
      
      if (retouch_offset == -1) {
	set_prelink_info(fd_elf_rw, 
			 retouch_original_value+random_offset);
      } else {
	set_relocation(fd_elf_rw, 
		       retouch_offset, 
		       retouch_original_value+random_offset);
      }
    }

  out:
    // clean up
    if (fd_elf_rw >= 0) { close(fd_elf_rw); fd_elf_rw = -1; }
    if (file_retouch) { fclose(file_retouch); file_retouch = NULL; }

    argIx++;
  }

  return 0;
}
