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

#include <SymbolTable.h>
#include <Image.h>

#include <debug.h>

#include <algorithm>

SymbolTable::SymbolTable(Image *img, const std::string &defaultSymbol,
                         uint32_t base) :
              mImg(img),
              mSortedFlag(false),
              mCumulativeTimeUpdatedFlag(false),
              mSymbols(),
              mDefaultSymbol(new Symbol(img, defaultSymbol, base, 0)),
              mPltSymbol(NULL) {
}

Symbol *SymbolTable::insert(const std::string &name,
                         uint32_t addr,
                         uint32_t size) {
    mSortedFlag = false;
    mCumulativeTimeUpdatedFlag = false;
    Symbol *sym = new Symbol(mImg, name, addr, size);
    mSymbols.push_back(sym);
    return sym;
}

Symbol *SymbolTable::insertPltSymbol(uint32_t addr, uint32_t size) {
    FAILIF(mPltSymbol != NULL, "PLT Symbol already set in %s!", mImg->getName().c_str());
    std::string pltSymbolName = mImg->getName() + "@plt";
    mPltSymbol = new Symbol(mImg, pltSymbolName, addr, size);
    return mPltSymbol;
}

static bool symbolCmp(const Symbol *lhs, const Symbol *rhs) {
    return lhs->getAddr() < rhs->getAddr();
}

/*
 * Make symbols are ordered in the table for fast query.
 */
void SymbolTable::sortSymbol() {
    if (!mSortedFlag) {
        std::sort(mSymbols.begin(), mSymbols.end(), symbolCmp);
        mSortedFlag = true;
    }
}

void SymbolTable::dumpCallEdge(const Options &options) {
    sortSymbol();
    uintmax_t cumulativeTime = getCumulativeTime();
    uintmax_t selfTime = getSelfTime();
    if (cumulativeTime == 0 &&
        selfTime == 0) {
        return;
    }
    PRINT("-------------------------------------------------------------\n");
    PRINT("Image           : %s\n", mImg->getName().c_str());
    PRINT("Cumulative time : %jd ms\n", options.toMS(cumulativeTime));
    PRINT("Self time       : %jd ms\n", options.toMS(selfTime));
    PRINT("  Function  %% time");
    PRINT("  cumulative        self");
    PRINT("       Count  Call by\n");
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        Symbol *sym = *itr;
        sym->dumpCallByInfo(options);
    }
}

Symbol *SymbolTable::getDefaultSymbol() {
    return mDefaultSymbol;
}
Symbol *SymbolTable::getPltSymbol() {
    return mPltSymbol;
}

void SymbolTable::dumpDotFormat(std::set<std::string> &outputSymbol,
                                uintmax_t totalTime) {
    this->getDefaultSymbol()->dumpDotFormat(outputSymbol, totalTime);
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        Symbol *sym = *itr;
        sym->dumpDotFormat(outputSymbol, totalTime);
    }
}

Symbol *SymbolTable::find(uint32_t addr) {
    if (mSymbols.empty()) return mDefaultSymbol;
    sortSymbol();
    for (std::vector<Symbol*>::reverse_iterator itr = mSymbols.rbegin();
         itr != mSymbols.rend();
         ++itr) {
        if (addr >= (*itr)->getAddr()) {
            return (*itr);
        }
    }
    if (mPltSymbol &&
        addr >= mPltSymbol->getAddr() &&
        addr <  mPltSymbol->getAddr() + mPltSymbol->getSize() ) {
        return mPltSymbol;
    }
    return mDefaultSymbol;
}

void SymbolTable::dump() {
    sortSymbol();
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        Symbol *sym = *itr;
        PRINT("%16x %16x %s\n", sym->getAddr(),
                                sym->getSize(),
                                sym->getName().c_str());
    }
}

void SymbolTable::dumpHistogram(uintmax_t totalTime, const Options &options) {
    sortSymbol();
    mDefaultSymbol->dumpHistogram(totalTime, options);
    if (mPltSymbol) mPltSymbol->dumpHistogram(totalTime, options);
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        (*itr)->dumpHistogram(totalTime, options);
    }
}

uintmax_t SymbolTable::getCumulativeTime() {
    uintmax_t cumulativeTime = mDefaultSymbol->getCumulativeTime();
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        cumulativeTime += (*itr)->getCumulativeTime();
    }
    return cumulativeTime;
}

uintmax_t SymbolTable::getSelfTime() {
    uintmax_t selfTime = mDefaultSymbol->getSelfTime();
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        selfTime += (*itr)->getSelfTime();
    }
    return selfTime;
}

void SymbolTable::updateCumulativeTime(){
    if (mCumulativeTimeUpdatedFlag) return;
    mCumulativeTimeUpdatedFlag = true;
    mDefaultSymbol->updateCumulativeTime();
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        (*itr)->updateCumulativeTime();
    }
}
