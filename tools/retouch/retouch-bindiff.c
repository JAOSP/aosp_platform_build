/*
 * Generic utility which compares two different builds of the same
 * executable and prepares a list of offsets for retouching. This is
 * intended for excutable *base* retouching, applicable to "normal"
 * executables as well as the dynamic linker (bionic/linker) which is
 * really a shared library built to a fixed offset.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define false 0
#define true 1
typedef int bool;

#define EXIT(x) { fprintf(stderr, "%s\n", (x)); exit(1); }

static int32_t offs_prev;
static uint32_t cont_prev;

int main(int argc, char **argv) {
    FILE *f_in1, *f_in2, *f_out;
    unsigned long build_delta, new_delta;

    if (argc != 4 && argc != 6) {
        EXIT("Usage: retouch-bindiff <delta_2minus1> "
             "<file_build1> <file_build2> [<new_delta> <file_out>]");
        return 1;
    }

    build_delta = 0;
    if (strlen(argv[1]) > 10) EXIT("Build delta too large.");
    sscanf(argv[1], "%x", &build_delta);
    if (build_delta == 0) EXIT("Could not parse the build delta.");

    f_in1 = fopen(argv[2], "rb");
    if (f_in1 == NULL) {
        EXIT("Could not open input file (build #1).");
    }
    f_in2 = fopen(argv[3], "rb");
    if (f_in2 == NULL) {
        EXIT("Could not open input file (build #2).");
    }

    f_out = NULL;
    if (argc == 6) {
        f_out = fopen(argv[5], "wb");
        if (f_out == NULL) {
            EXIT("Could not open output file.");
        }

        new_delta = 0;
        sscanf(argv[4], "%x", &new_delta);
        if (new_delta == 0) EXIT("Could not parse new delta.");
    }

    long file_recIx = 0;
    while (true) {
        int char_f1, char_f2;
        uint32_t rec_f1 = 0, rec_f2 = 0, rec_out;
        int recIx;

        for (recIx=0; recIx<4; recIx++) {
            char_f1 = fgetc(f_in1);
            char_f2 = fgetc(f_in2);
            if (char_f1 == EOF && char_f2 == EOF) break;
            if (char_f1 == EOF || char_f2 == EOF) {
                EXIT("File lengths differ. Danger!");
            }

            rec_f1 = (rec_f1 >> 8) | ((uint8_t)char_f1 << 24);
            rec_f2 = (rec_f2 >> 8) | ((uint8_t)char_f2 << 24);
        }
        rec_out = rec_f1;
        if (recIx < 4) {
            if (rec_f1 != rec_f2)
                EXIT("Truncated last record is mismatched!");

            if (f_out != NULL && recIx > 0)
                fwrite(((char *)&rec_out)+4-recIx, 1, recIx, f_out);
            goto out;
        }

        if (rec_f1 != rec_f2) {
            // first: run a sanity check
            if ((rec_f2-rec_f1) != build_delta) {
                if (build_delta == 1)
                    build_delta = rec_f2-rec_f1;
                else
                    EXIT("Record delta is different from build delta!");
            }

            rec_out += new_delta;

            // let's generate the retouch entry
            printf("%ld %u\n", file_recIx*4, rec_f1);
        }

        if (f_out != NULL)
            fwrite(((char *)&rec_out), 1, 4, f_out);

        file_recIx++;
    }

 out:
    fclose(f_in1);
    fclose(f_in2);
    if (f_out != NULL) fclose(f_out);
    return 0;
}
