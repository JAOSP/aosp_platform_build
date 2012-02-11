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

#include <Image.h>
#include <Options.h>
#include <gelf.h>
#include <debug.h>

#include <string.h>
#include <stdint.h>
#include <assert.h>
#include <limits.h>
#include <fcntl.h>

Image::Image(const std::string &imageName, uint32_t base,
             uint32_t size, const Bins &bins,
             const Options &options, bool isExe) :
          mOptions(options),
          mImageName(imageName),
          mBase(base),
          mSize(size),
          mBins(bins),
          mSymbolTable(this,
                       std::string("<")+imageName+std::string(">"),
                       base),
          mUpdateHistogramFlag(false),
          mIsExecutable(isExe) {
}

Image::~Image() {
}

bool Image::addrInImage(uint32_t addr) {
    return (addr >= mBase &&
            addr <  (mBase+mSize));
}

Symbol *Image::querySymbol(uint32_t addr) {
    return mSymbolTable.find(addr);
}

void Image::dumpDotFormat(std::set<std::string> &outputSymbol,
                          uintmax_t totalTime) {
    updateHistogram();
    mSymbolTable.dumpDotFormat(outputSymbol, totalTime);
}

void Image::dumpHistogram(uintmax_t totalTime) {
    updateHistogram();
    mSymbolTable.dumpHistogram(totalTime, mOptions);
}

void Image::updateHistogram() {
    if (mUpdateHistogramFlag) return;
    mUpdateHistogramFlag = true;

    size_t i, binLen = mBins.size();
    /*
     * Caclulate self execution time for each symbol,
     * self time mean the execution time exclude the innder function.
     */
    for (i=0;i<binLen;++i) {
        if (mBins[i] == 0) continue;
        uint32_t addr = (i * 2 * 2)  + mBase;
        Symbol *symbol = mSymbolTable.find(addr);
        INFO("Symbol %s(%x) : %ju ms\n",
             symbol->getName().c_str(),
             addr, mOptions.toMS(mBins[i]));
        symbol->setSelfTime(symbol->getSelfTime() + mBins[i]);
    }

    /*
     * Now, caclulate cumulative execution time for each symbol,
     * cumulative time inculude the execution time of innder function.
     */
    mSymbolTable.updateCumulativeTime();
}

int findFile(const std::string &filename,
             const Options &options,
             bool isExecutable) {
    const LibPaths &libPaths = options.libPaths;
    int fd;
    if (isExecutable) {
        if (filename != basename(options.imgFile.c_str()) ) {
            WARING("Waring! the image name of executable are "
                   "difference from the profiling file.\n");
        }
        fd = open(options.imgFile.c_str(), O_RDONLY);
        if (fd > 0) return fd;
    }

    fd = open(filename.c_str(), O_RDONLY);
    if (fd > 0) return fd;
    for (LibPaths::const_iterator itr = libPaths.begin();
         itr != libPaths.end();
         ++itr) {
        std::string path = *itr;
        path += "/";
        path += filename;
        fd = open(path.c_str(), O_RDONLY);
        if (fd > 0) return fd;
    }
    INFO("Can't found %s\n", filename.c_str());
    FAILIF(isExecutable, "Can't find executable image '%s'\n",
                         filename.c_str());
    return -1;
}

bool Image::readSymbol() {
    /*
     * Invalidate the histogram data.
     */
    mUpdateHistogramFlag = false;

    int fd = findFile(mImageName, mOptions, mIsExecutable);

    if (fd < 0) return false;
    FAILIF (elf_version(EV_CURRENT) == EV_NONE, "libelf is out of date!\n");
    Elf *elf = elf_begin(fd, ELF_C_READ, NULL);
    if (elf_kind(elf) != ELF_K_ELF) {
        return false;
    }

    Elf_Scn *scn = NULL;
    GElf_Shdr shdr;
    GElf_Ehdr ehdr;
    size_t shstrndx;
    Elf32_Word symtab_or_dynsym = SHT_DYNSYM;
    FAILIF_LIBELF(elf_getshstrndx(elf, &shstrndx) < 0,
                  elf_getshstrndx);
    FAILIF_LIBELF(0 == gelf_getehdr(elf, &ehdr), gelf_getehdr);

    /*
     * Get symbol info from SHT_SYMTAB section as possible
     */
    while ((scn = elf_nextscn (elf, scn)) != NULL) {
        FAILIF_LIBELF(NULL == gelf_getshdr(scn, &shdr), gelf_getshdr);
        if (SHT_SYMTAB == shdr.sh_type) {
            symtab_or_dynsym = SHT_SYMTAB;
        }
    }

    scn = NULL;

    while ((scn = elf_nextscn (elf, scn)) != NULL) {
        FAILIF_LIBELF(NULL == gelf_getshdr(scn, &shdr), gelf_getshdr);
        const char *section_name = elf_strptr(elf, shstrndx, shdr.sh_name);
        if (strcmp(section_name, ".plt") == 0) {
            /* Insert <image_name>@plt symbol to symbol table */
            mSymbolTable.insertPltSymbol(shdr.sh_addr+mBase,
                                         shdr.sh_size);
        }
        if (symtab_or_dynsym == shdr.sh_type) {
            Elf_Data *symdata;
            size_t elsize;
            symdata = elf_getdata (scn, NULL); /* get the symbol data */
            FAILIF_LIBELF(NULL == symdata, elf_getdata);

            size_t shnum;
            FAILIF_LIBELF(elf_getshnum (elf, &shnum) < 0, elf_getshnum);
            elsize = gelf_fsize(elf, ELF_T_SYM, 1, ehdr.e_version);

            size_t index;
            for (index = 0; index < symdata->d_size / elsize; index++) {
                const char *symName;
                GElf_Sym sym_mem;
                GElf_Sym *sym;
                /* Get the symbol. */
                sym = gelf_getsymshndx (symdata, NULL,
                                        index, &sym_mem, NULL);
                FAILIF_LIBELF(sym == NULL, gelf_getsymshndx);
                /* We only care about function here. */
                if (ELF32_ST_TYPE(sym->st_info) != STT_FUNC) {
                     continue;
                }
                /* Insert to symbol talbe if not undefine symbol */
                if (sym->st_shndx != SHN_UNDEF &&
                    sym->st_shndx < shnum) {
                    symName = elf_strptr(elf, shdr.sh_link, sym->st_name);
                    Symbol *symbol = mSymbolTable.insert(symName,
                                                         sym->st_value+mBase,
                                                         sym->st_size);
                    INFO("Symbol %s, address : %x size : %x\n", symName,
                         symbol->getAddr(),
                         symbol->getSize());
                }
            }
        }

    }
    elf_end(elf);
    close(fd);

    return true;
}

const std::string &Image::getName() const{
    return mImageName;
}

void Image::dumpCallEdge() {
    mSymbolTable.dumpCallEdge(mOptions);
}
