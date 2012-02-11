/*
 * Copyright (C) 2011 The Android Open Source Project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include <stdint.h>
#include <Aprof.h>
#include <Options.h>
#include <libaprof.h>

#include <string>
#include <set>

#include <string.h>
#include <assert.h>
#include <limits.h>
#include <fcntl.h>
#include <gelf.h>
#include <debug.h>

Aprof::Aprof(Options &options) :
           mOptions(options),
           mImages(options) {
    /*
     * Read the profiling file, and read symbols.
     */
    readProfileFile();
}

Aprof::~Aprof() {
}

void Aprof::dumpDotFormat() {
    PRINT("digraph Aprof {\n"
          "    node [fontname=Arial, style=filled, "
          "height=0, width=0, shape=box, fontcolor=white];\n"
          "    edge [fontname=Arial];\n");
    mImages.dumpDotFormat();
    PRINT("}\n");
}

void Aprof::dumpHistogram() {
    mImages.dumpHistogram();
}

void Aprof::dumpCallEdge() {
    PRINT("\nCall graph (explanation follows)\n\n");
    mImages.dumpCallEdge();
}

bool Aprof::readHistogram(FILE *fp, bool isExe) {
    uint32_t base=0;
    uint32_t size=0;
    uint32_t binSize=0;
    uint16_t *bins;
    uint32_t name_len = 0;
    size_t binMappedSize;
    char filename[PATH_MAX];
    fread(&name_len, sizeof(uint32_t), 1, fp);
    fread(filename, name_len, 1, fp);
    filename[name_len] = '\0';
    fread(&base, sizeof(uint32_t), 1, fp);
    fread(&size, sizeof(uint32_t), 1, fp);
    fread(&binSize, sizeof(uint32_t), 1, fp);
    fread(&binMappedSize, sizeof(uint32_t), 1, fp);
    INFO("%s : base %x -> %x, bin size : %d * %d\n",
         filename, base, base+size, binSize, binMappedSize);
    bins = new uint16_t[binSize];
    fread(bins, sizeof(uint16_t), binSize, fp);
    Image *img = mImages.addImage(filename, base,
                                  size, Bins(bins, bins+binSize),
                                  isExe);
    img->readSymbol();
    delete []bins;
    return true;
}

bool Aprof::readCallGraph(FILE *fp) {
    uint32_t edges, i;
    uint32_t callerPC;
    uint32_t calleePC;
    uint32_t count;
    fread(&edges, sizeof(uint32_t), 1, fp);
    INFO("Total %d edges\n", edges);
    for (i=0;i<edges;i++) {
        fread(&callerPC, sizeof(uint32_t), 1, fp);
        fread(&calleePC, sizeof(uint32_t), 1, fp);
        fread(&count, sizeof(uint32_t), 1, fp);
        mImages.addEdge(callerPC, calleePC, count);
        INFO("  %x -> %x (%d)\n", callerPC, calleePC, count);
    }
    return true;
}

bool Aprof::readHeader(FILE *fp) {
    const char aprof_tag[] = APROF_TAG;
    char tag[APROF_TAG_LENGTH];
    uint32_t version;
    uint32_t sample_rate;
    uint32_t pointer_size;

    fread(&tag, APROF_TAG_LENGTH, 1, fp);
    if (memcmp(tag, aprof_tag, APROF_TAG_LENGTH)) {
        return false;
    }

    fread(&version, sizeof(uint32_t), 1, fp);
    fread(&sample_rate, sizeof(uint32_t), 1, fp);
    fread(&pointer_size, sizeof(uint32_t), 1, fp);
    mOptions.version = version;
    mOptions.sampleRate = sample_rate;
    mOptions.pointerSize = pointer_size;
    INFO("version : %d\n", version);
    INFO("sample rate : %d times/ second\n", sample_rate);
    INFO("pointer size : %d\n", pointer_size);

    FAILIF(pointer_size != 4, "Dont's support pointer size other than 4 now.");
    return true;
}

bool Aprof::readProfileFile() {
    FILE *fp = fopen(mOptions.profFile.c_str(), "r");
    FAILIF(fp == NULL, "Fail to open profiling file '%s'\n",
                       mOptions.profFile.c_str());
    FAILIF(!readHeader(fp), "%s : bad aprof profiling file\n",
                            mOptions.profFile.c_str());
    uint32_t header_type;
    while ( fread(&header_type, sizeof(uint32_t), 1, fp) ) {
        switch (header_type) {
            /*
             * The difference between APROF_EXECUTABLE_HISTOGRAM_HEADER and
             * APROF_HISTOGRAM_HEADER is the image search path.
             */
            case APROF_EXECUTABLE_HISTOGRAM_HEADER:
                INFO("read APROF_EXECUTABLE_HISTOGRAM_HEADER\n");
                readHistogram(fp, true);
                break;
            case APROF_HISTOGRAM_HEADER:
                INFO("read APROF_HISTOGRAM_HEADER\n");
                readHistogram(fp, false);
                break;
            case APROF_CALL_GRAPH_HEADER:
                INFO("read APROF_CALL_GRAPH_HEADER\n");
                readCallGraph(fp);
                break;
            default:
                FAILIF(1, "unknown header type %d\n", header_type);
                return false;
        }
    }
    return true;
}
