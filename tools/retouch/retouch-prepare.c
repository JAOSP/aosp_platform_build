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

#define false 0
#define true 1

static int32_t offs_prev;
static uint32_t cont_prev;

void init_compression_state(void) {
    offs_prev = 0;
    cont_prev = 0;
}

//
// We use three encoding schemes; this takes care of much of the redundancy
// inherent in lists of relocations:
//
//   * two bytes, leading 1, 2b for d_offset ("s"), 13b for d_contents ("c")
//
//     76543210 76543210
//     1ssccccc cccccccc
//
//   * three bytes, leading 01, 2b for delta offset, 20b for delta contents
//
//     76543210 76543210 76543210
//     01sscccc cccccccc cccccccc
//
//   * eigth bytes, leading 00, 30b for offset, 32b for contents
//
//     76543210 76543210 76543210 76543210
//     00ssssss ssssssss ssssssss ssssssss + 4 bytes contents
//
// NOTE 1: All deltas are w.r.t. the previous line in the list.
// NOTE 2: Two-bit ("ss") offsets mean: "00"=4, "01"=8, "10"=12, and "11"=16.
// NOTE 3: Delta contents are signed. To map back to a int32 we refill with 1s.
// NOTE 4: Special encoding for -1 offset. Extended back to 32b when decoded.
//

bool encode(FILE *f_out, int32_t offset, uint32_t contents) {
    int64_t d_offs = offset-offs_prev;
    int64_t d_cont = (int64_t)contents-(int64_t)cont_prev;

    uint8_t output[8];
    uint32_t output_size;

    if ((d_offs > 3) &&
        (d_offs % 4) == 0 &&
        (d_offs / 4) < 5 &&
        (d_cont < 4000) &&
        (d_cont > -4000)) {
        // we can fit in 2 bytes
        output[0] =
          0x80 |
          (((d_offs/4)-1) << 5) |
          (((uint64_t)d_cont & 0x1f00) >> 8);
        output[1] =
          ((uint64_t)d_cont & 0xff);
        output_size = 2;
    } else if ((d_offs > 3) &&
               (d_offs % 4) == 0 &&
               (d_offs / 4) < 5 &&
               (d_cont < 510000) &&
               (d_cont > -510000)) {
        // fit in 3 bytes
        output[0] =
          0x40 |
          (((d_offs/4)-1) << 4) |
          (((uint64_t)d_cont & 0xf0000) >> 16);
        output[1] =
          ((uint64_t)d_cont & 0xff00) >> 8;
        output[2] =
          ((uint64_t)d_cont & 0xff);
        output_size = 3;
    } else {
        // fit in 8 bytes; we can't support files bigger than (1GB-1)
        // with this encoding: no library is that big anyway..
        if (offset < -1 || offset > 0x3ffffffe) return false;
        output[0] = (offset & 0x3f000000) >> 24;
        output[1] = (offset & 0xff0000) >> 16;
        output[2] = (offset & 0xff00) >> 8;
        output[3] = (offset & 0xff);
        output[4] = (contents & 0xff000000) >> 24;
        output[5] = (contents & 0xff0000) >> 16;
        output[6] = (contents & 0xff00) >> 8;
        output[7] = (contents & 0xff);
        output_size = 8;
    }

    if (fwrite(&output, 1, output_size, f_out) != output_size) return false;

    offs_prev = offset;
    cont_prev = contents;
    return true;
}

#define MAX_FULL_NAME 1024

#define FAILIF(cond, msg...) do {   \
      if (cond) {                   \
          fprintf(stderr, ##msg);   \
          exit(1);                  \
      }                             \
  } while(0)

int is_host_little(void) {
    short val = 0x10; return ((char *)&val)[0] != 0;
}

uint32_t switch_endianness(uint32_t val) {
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
        FAILIF(!encode(f_out, -1, info.mmap_addr),
               "Could not encode prelink info!\n");
    } else {
        /* Different endianness */
        FAILIF(!encode(f_out, -1, switch_endianness(info.mmap_addr)),
               "Could not encode prelink info!\n");
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
    FAILIF(!encode(f_out, offset,
                   (!(elf_little ^ is_host_little()))?
                   retouch_contents:
                   switch_endianness(retouch_contents)),
           "Could not encode relocation!\n");
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

    // open the output file
    FAILIF((file_retouch = fopen(argv[3], "wb")) == NULL,
           "Could not fopen(\"%s\")\n",
           argv[3]);

    // loop over all touch-up entries
    line_count = 0;
    current_lib_full_name[0] = 0;
    init_compression_state();

    // open the apriori relocation list for retouching; if
    // non-existent, we must be dealing with a prebuilt library
    if ((file_apriori = fopen(argv[1], "r")) == NULL) {
        printf("Assuming file \"%s\" is prebuilt. "
               "Will output a single retouch entry.\n",
               argv[2]);
    } else {
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
              printf("Retouch complete (%llu entries processed).\n",
                     line_count);
              break;
            }
            line_count++;

            // find the section and map the section+offset to a file offset
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
                FAILIF((elf_sname = elf_strptr(e, shstrndx, shdr.sh_name)) ==
                       NULL,
                       "elf_strptr() failed: %s\n",
                       elf_errmsg(-1));
                if (strcmp(elf_sname, retouch_sname) == 0) {
                    // found the section: check size for sanity
                    if (shdr.sh_size < retouch_offset) {
                        printf("Retouch offset %llu is greater "
                               "than the section size %llu\n",
                               retouch_offset, shdr.sh_size);
                    }

                    // fix contents, and we are done
                    uint64_t file_offset = shdr.sh_offset + retouch_offset;
                    output_relocation(file_retouch,
                                      fd_elf_ro,
                                      ehdr.e_ident[EI_DATA] == ELFDATA2LSB,
                                      file_offset);
                    break;
                }
            }
            FAILIF(sectIx >= shnum,
                   "Could not find section: %s\n",
                   retouch_sname);
        }
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
