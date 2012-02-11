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

#ifndef _IMAGE_COLLECTION_H
#define _IMAGE_COLLECTION_H

#include <Image.h>
#include <Options.h>
#include <debug.h>

#include <list>
#include <set>
#include <string>
#include <stdint.h>

class ImageCollection {
public:
    ImageCollection(const Options &options);
    void insert(Image *img);
    Image *addImage(const std::string &imageName, uint32_t base,
                    uint32_t size, const Bins &bins, bool isExe);
    void updateHistogram();
    Image *findImage(uint32_t addr);
    void addEdge(uint32_t callerPC, uint32_t calleePC, uint32_t count);

    void dumpDotFormat();
    void dumpCallEdge();
    void dumpHistogram();
private:
    typedef std::list<Image*> _ImageCollection;
    _ImageCollection mImages;
    const Options &mOptions;
    uintmax_t mTotalTime;
};

#endif /* _IMAGE_COLLECTION_H */
