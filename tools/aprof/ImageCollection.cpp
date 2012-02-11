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

#include <ImageCollection.h>

ImageCollection::ImageCollection(const Options &options) :
                  mImages(),
                  mOptions(options),
                  mTotalTime(0) {
}

Image *ImageCollection::addImage(const std::string &imageName,
                                 uint32_t base,
                                 uint32_t size,
                                 const Bins &bins,
                                 bool isExe) {
    Image *img = new Image(imageName, base, size, bins, mOptions, isExe);
    mImages.push_back(img);
    for (Bins::const_iterator itr = bins.begin();
         itr != bins.end();
         ++itr) {
        mTotalTime += *itr;
    }
    return img;
}

void ImageCollection::dumpDotFormat() {
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        (*itr)->updateHistogram();
    }
    std::set<std::string> outputSymbol;
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        (*itr)->dumpDotFormat(outputSymbol, mTotalTime);
    }
}

void ImageCollection::dumpHistogram() {
    PRINT("  %%    cumulative     self ");
    PRINT("                self        total\n");
    PRINT(" time    seconds     seconds");
    PRINT("      calls    ms/call    ms/call   name\n");
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        (*itr)->updateHistogram();
    }
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        (*itr)->dumpHistogram(mTotalTime);
    }
}

Image *ImageCollection::findImage(uint32_t addr) {
    /*
     * Find current address is locate in which image.
     */
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        if ((*itr)->addrInImage(addr)) {
            return *itr;
        }
    }
    return NULL;
}

void ImageCollection::dumpCallEdge() {
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        Image *img = *itr;
        img->dumpCallEdge();
    }
}

void ImageCollection::addEdge(uint32_t callerPC,
                              uint32_t calleePC,
                              uint32_t count) {
    Image *callerImg = findImage(callerPC);
    Image *calleeImg = findImage(calleePC);
    if (callerImg == NULL) {
        ERROR("Unknown calller address %x", callerPC);
        return;
    }
    if (calleeImg == NULL) {
        ERROR("Unknown calllee address %x", calleePC);
        return;
    }
    Symbol *caller = callerImg->querySymbol(callerPC);
    Symbol *callee = calleeImg->querySymbol(calleePC);

    caller->addCalledSymbol(callee, count);
    callee->addCallBySymbol(caller, count);
}
