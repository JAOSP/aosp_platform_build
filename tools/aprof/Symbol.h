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

#ifndef _SYMBOL_H
#define _SYMBOL_H

#include <vector>
#include <map>
#include <set>
#include <string>
#include <stdint.h>

class Image;
class Symbol;
class Options;

typedef std::map<Symbol *, unsigned> CallInfo;

class Symbol {
public:
    Symbol(Image *img, const std::string &name,
           uint32_t addr, uint32_t size);

    const std::string &getName() const;
    std::string getDotNodeName() const;
    uint32_t getAddr() const;
    uint32_t getSize() const;

    uintmax_t getCumulativeTime() const;
    uintmax_t getSelfTime() const;

    void setCumulativeTime(uintmax_t time);
    void setSelfTime(uintmax_t time);

    void dumpHistogram(uintmax_t totalTime, const Options &options);
    void updateCumulativeTime();

    void dumpDotFormat(std::set<std::string> &outputSymbol,
                       uintmax_t totalTime);

    bool inSameImage(const Symbol *sym) const;

    void addCalledSymbol(Symbol *sym, unsigned count);
    void addCallBySymbol(Symbol *sym, unsigned count);

    void dumpCallByInfo(const Options &options) const;
private:
    void updateCumulativeTime(uintmax_t cumulativeTime);

    Image *mImg;
    std::string mName;
    uint32_t mAddr;
    uint32_t mSize;

    uintmax_t mCumulativeTime;
    uintmax_t mSelfTime;

    CallInfo mCalled;
    CallInfo mCallBy;

    /*
     * Use for update cumulative time
     */
    Symbol *tag;
};

#endif
