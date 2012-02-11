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

#include <Options.h>
#include <Aprof.h>

int main(int argc, char **argv) {
    Options opts(argc, argv);
    Aprof aprof(opts);
    switch (opts.outputFormat) {
       case Options::TEXT:
           aprof.dumpHistogram();
           aprof.dumpCallEdge();
           break;
       case Options::DOT:
           aprof.dumpDotFormat();
           break;
    }
    return 0;
}
