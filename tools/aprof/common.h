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

#ifndef COMMON_H
#define COMMON_H

#include <libelf.h>
#include <elf.h>

#define unlikely(expr) __builtin_expect (expr, 0)
#define likely(expr)   __builtin_expect (expr, 1)

#define MIN(a,b) ((a)<(b)?(a):(b)) /* no side effects in arguments allowed! */

static inline int is_host_little(void)
{
    short val = 0x10;
    return ((char *)&val)[0] != 0;
}

static inline long switch_endianness(long val)
{
	long newval;
	((char *)&newval)[3] = ((char *)&val)[0];
	((char *)&newval)[2] = ((char *)&val)[1];
	((char *)&newval)[1] = ((char *)&val)[2];
	((char *)&newval)[0] = ((char *)&val)[3];
	return newval;
}

#endif/*COMMON_H*/
