/*
 * WARNING: This is test code. You can use this tool to check that
 * compressed relocaion lists are valid, in case you have doubts.
 * This is strictly for development purposes.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define false 0
#define true 1
typedef int bool;

#define EXIT(x) { fprintf(stderr, "%s\n", (x)); exit(1); }

int32_t offs_prev;
uint32_t cont_prev;

void init_compression_state(void) {
  offs_prev = 0;
  cont_prev = 0;
}

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

bool decode(FILE *f_in, int32_t *offset, uint32_t *contents) {
  int one_char, input_size, charIx;
  uint8_t input[8];

  one_char = fgetc(f_in);
  if (one_char == EOF) return false;
  input[0] = (uint8_t)one_char;
  if (input[0] & 0x80)
    input_size = 2;
  else if (input[0] & 0x40)
    input_size = 3;
  else
    input_size = 8;

  // we already read one byte..
  charIx = 1;
  while (charIx < input_size) {
    one_char = fgetc(f_in);
    if (one_char == EOF) return false;
    input[charIx++] = (uint8_t)one_char;
  }

  if (input_size == 2) {
    *offset = offs_prev + (((input[0]&0x60)>>5)+1)*4;

    // if the original was negative, we need to 1-pad before applying delta
    int32_t tmp = (((input[0] & 0x0000001f) << 8) | input[1]);
    if (tmp & 0x1000) tmp = 0xffffe000 | tmp;
    *contents = cont_prev + tmp;
  } else if (input_size == 3) {
    *offset = offs_prev + (((input[0]&0x30)>>4)+1)*4;

    // if the original was negative, we need to 1-pad before applying delta
    int32_t tmp = (((input[0] & 0x0000000f) << 16) |
		   (input[1] << 8) |
		   input[2]);
    if (tmp & 0x80000) tmp = 0xfff00000 | tmp;
    *contents = cont_prev + tmp;
  } else {
    *offset =
      (input[0]<<24) |
      (input[1]<<16) |
      (input[2]<<8) |
      input[3];
    if (*offset == 0x3fffffff) *offset = -1;
    *contents =
      (input[4]<<24) |
      (input[5]<<16) |
      (input[6]<<8) |
      input[7];
  }

  offs_prev = *offset;
  cont_prev = *contents;

  return true;
}

int main(int argc, char **argv) {
  FILE *f_in, *f_out;
  int32_t r_offs;
  uint32_t r_cont;
  bool decoding;

  if (argc != 3 && (argc != 4 || strcmp(argv[1], "-d"))) {
    EXIT("Usage: retouch-deltas [-d] <infile> <outfile>");
    return 1;
  }

  if (argc == 3)
    decoding = false;
  else
    decoding = true;

  f_in = fopen(argv[argc-2], decoding?"rb":"r");
  if (f_in == NULL) {
    EXIT("Could not open input file.");
  }
  f_out = fopen(argv[argc-1], decoding?"w":"wb");
  if (f_in == NULL) {
    EXIT("Could not open output file.");
  }

  init_compression_state();
  while (!feof(f_in)) {
    if (decoding) {
      if (!decode(f_in, &r_offs, &r_cont)) {
	if (!feof(f_in)) EXIT("Could not decode.");
      } else {
	fprintf(f_out, "%d %u\n", r_offs, r_cont);
      }
    } else {
      if (fscanf(f_in, "%d %u", &r_offs, &r_cont) != 2) {
	if (!feof(f_in)) EXIT("Could not encode (read failed).");
	break;
      }
      if (!encode(f_out, r_offs, r_cont)) EXIT("Could not encode.");
    }
  }
  fclose(f_in);
  fclose(f_out);

  return 0;
}
