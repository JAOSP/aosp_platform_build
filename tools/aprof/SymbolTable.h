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

#ifndef _SYMBOL_TABLE_H
#define _SYMBOL_TABLE_H

#include <Symbol.h>

class SymbolTable {
public:
    SymbolTable(Image *img, const std::string &defaultSymbol, uint32_t base);
    Symbol *insert(const std::string &name, uint32_t addr, uint32_t size);
    Symbol *insertPltSymbol(uint32_t addr, uint32_t size);
    Symbol *find(uint32_t addr);
    void dump();
    void dumpHistogram(uintmax_t totlaTime, const Options &options);
    void dumpCallEdge(const Options &options);
    void dumpDotFormat(std::set<std::string> &outputSymbol,
                       uintmax_t totalTime);

    uintmax_t getCumulativeTime();
    uintmax_t getSelfTime();

    void updateCumulativeTime();
    Symbol *getDefaultSymbol();
    Symbol *getPltSymbol();
private:
    Image *mImg;
    void sortSymbol();
    bool mSortedFlag;
    bool mCumulativeTimeUpdatedFlag;
    std::vector<Symbol*> mSymbols;
    Symbol *mDefaultSymbol;
    Symbol *mPltSymbol;
};


#endif /* _SYMBOL_TABLE_H */
