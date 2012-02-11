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

#ifndef _IMAGE_H
#define _IMAGE_H

#include <Options.h>
#include <SymbolTable.h>

#include <map>
#include <set>
#include <string>
#include <vector>
#include <stdint.h>

typedef std::map<Symbol*, uint32_t> Histogram;
typedef std::vector<uint16_t> Bins;

class Image {
public:

    Image(const std::string &imageName, uint32_t base,
          uint32_t size, const Bins &bins,
          const Options &options, bool isExe);
    ~Image();

    const std::string &getName() const;
    bool readSymbol();
    void updateHistogram();
    bool addrInImage(uint32_t addr);
    Symbol *querySymbol(uint32_t addr);
    void dumpCallEdge();
    void dumpHistogram(uintmax_t totalTime);
    void dumpDotFormat(std::set<std::string> &outputSymbol,
                       uintmax_t totalTime);
private:
    const Options &mOptions;
    std::string mImageName;
    uint32_t mBase;
    uint32_t mSize;
    Bins mBins;
    SymbolTable mSymbolTable;
    bool mUpdateHistogramFlag;
    bool mIsExecutable;
};

#endif /* _IMAGE_H */
