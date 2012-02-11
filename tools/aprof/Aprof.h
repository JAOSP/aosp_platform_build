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

#ifndef _PROFILES_H
#define _PROFILES_H

#include <stdint.h>
#include <string>
#include <stdio.h>
#include <elf.h>
#include <list>
#include <vector>
#include <map>
#include <Options.h>
#include <SymbolTable.h>
#include <ImageCollection.h>

class Options;

class Aprof {
public:
    Aprof(Options &options);
    ~Aprof();

    void dumpHistogram();
    void dumpCallEdge();
    void dumpDotFormat();

private:
    Options &mOptions;
    ImageCollection mImages;

    bool readHeader(FILE *fp);
    bool readProfileFile();
    bool readHistogram(FILE *fp, bool isExe);
    bool readCallGraph(FILE *fp);
    bool readSymbols();
    void updateHistogram();
};

#endif /* _PROFILES_H */
