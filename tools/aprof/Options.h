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

#ifndef _OPTIONS_H
#define _OPTIONS_H

#include <string>
#include <vector>
#include <stdint.h>

typedef std::vector<std::string> LibPaths;
extern int verbose;

class Options {
public:
    Options(int argc, char **argv);

    std::string imgFile;
    std::string profFile;
    LibPaths libPaths;

    uint32_t version;
    uint32_t sampleRate;
    uint32_t pointerSize;

    uintmax_t toMS(uintmax_t time) const;

    enum OutputFormat{
        TEXT,
        DOT,
    };
    enum OutputFormat outputFormat;
private:
    void parseCmdLine(int argc, char **argv);
};

#endif
