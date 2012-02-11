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
#include <getopt.h>
#include <stdio.h>
#include <debug.h>

extern char *optarg;
extern int optind, opterr, optopt;
int quiet_flag;
int verbose;

static struct option long_options[] = {
    {"quiet",         no_argument,       0, 'Q'},
    {"lookup",        required_argument, 0, 'L'},
    {"verbose",       no_argument,       0, 'v'},
    {"help",          no_argument,       0, 'h'},
    {"dot",           no_argument,       0, 'd'},
    {0, 0, 0, 0},
};

/* This array must parallel long_options[] */
static const char *descriptions[] = {
    "suppress informational and non-fatal error messages",
    "provide a directory for library lookup",
    "print verbose output",
    "print help screen",
    "output as dot file format",
};


static void print_help(const char *name) {
    fprintf(stdout,
            "invokation:\n"
            "\t%s executable_file -Ldir1 [-Ldir2 ...]\n"
            "\t%s executable_file profiling_file -Ldir1 [-Ldir2 ...]\n"
            "\t%s executable_file profiling_file -Ldir1 [-Ldir2 ...] -d"
            " | dot -Tpng -o out.png\n"
            "\t%s -h\n\n", name, name, name, name);
    fprintf(stdout, "options:\n");
    struct option *opt = long_options;
    const char **desc = descriptions;
    while (opt->name) {
        fprintf(stdout, "\t-%c/--%s%s: %s\n",
                opt->val,
                opt->name,
                (opt->has_arg ? " (argument)" : ""),
                *desc);
        opt++;
        desc++;
    }
}

void Options::parseCmdLine(int argc, char **argv) {
    int c;

    while (1) {
        /* getopt_long stores the option index here. */
        int option_index = 0;

        c = getopt_long (argc, argv,
                         "QL:vhd",
                         long_options,
                         &option_index);
        /* Detect the end of the options. */
        if (c == -1) break;

        if (isgraph(c)) {
            INFO ("option -%c with value `%s'\n", c, (optarg ?: "(null)"));
        }

#define SET_STRING_OPTION(name) do {                                   \
    ASSERT(optarg);                                                    \
    (*name) = strdup(optarg);                                          \
} while(0)

#define SET_REPEATED_STRING_OPTION(arr, num, size) do {                \
	if (*num == size) {                                                \
		size += 10;                                                    \
		*arr = (char **)REALLOC(*arr, size * sizeof(char *));          \
	}                                                                  \
	SET_STRING_OPTION(((*arr) + *num));                                \
	(*num)++;                                                          \
} while(0)

#define SET_INT_OPTION(val) do {                                       \
    ASSERT(optarg);                                                    \
	if (strlen(optarg) >= 2 && optarg[0] == '0' && optarg[1] == 'x') { \
			FAILIF(1 != sscanf(optarg+2, "%x", val),                   \
				   "Expecting a hexadecimal argument!\n");             \
	} else {                                                           \
		FAILIF(1 != sscanf(optarg, "%d", val),                         \
			   "Expecting a decimal argument!\n");                     \
	}                                                                  \
} while(0)

        switch (c) {
        case 0:
            /* If this option set a flag, do nothing else now. */
            if (long_options[option_index].flag != 0)
                break;
            INFO ("option %s", long_options[option_index].name);
            if (optarg)
                INFO (" with arg %s", optarg);
            INFO ("\n");
            break;
        case 'L':
            libPaths.push_back(optarg);
            break;
        case 'h': print_help(argv[0]); exit(1); break;
        case 'v': verbose = 1; break;
        case 'd': outputFormat = DOT; break;
        case '?':
            /* getopt_long already printed an error message. */
            break;

#undef SET_STRING_OPTION
#undef SET_REPEATED_STRING_OPTION
#undef SET_INT_OPTION

        default:
            FAILIF(1, "Unknown option");
        }
    }

    switch (argc - optind) {
        case 1:
            imgFile = argv[optind];
            profFile = "agmon.out";
            break;
        case 2:
            imgFile = argv[optind];
            profFile = argv[optind+1];
            break;
        default:
            print_help(argv[0]); exit(1);
            break;
    }
}

Options::Options(int argc, char **argv) :
    outputFormat(TEXT) {
    parseCmdLine(argc, argv);
    INFO("Image file : %s\n", imgFile.c_str());
    INFO("Profile file : %s\n", profFile.c_str());
    for (std::vector<std::string>::iterator itr = libPaths.begin();
         itr != libPaths.end();
         ++itr) {
        INFO("lib path : %s \n", itr->c_str());
    }
};

static const uintmax_t one_second = 1000;
uintmax_t Options::toMS(uintmax_t time) const {
    return (time * one_second) / sampleRate;
};
