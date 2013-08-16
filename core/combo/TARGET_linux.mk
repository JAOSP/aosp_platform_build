#
# Copyright (C) 2006 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Common configuration for Linux on ARM, MIPS, and X86.
# Included by combo/TARGET_linux-arm.mk, combo/TARGET_linux-mips.mk,
# and TARGET_linux-x86.mk

ifeq ($(strip $(TARGET_GCC_VERSION_EXP)),)
  TARGET_GCC_VERSION := 4.7
else
  TARGET_GCC_VERSION := $(TARGET_GCC_VERSION_EXP)
endif

# Include the arch-variant-specific configuration file.
# Its role is to define various ARCH_X86_HAVE_XXX feature macros,
# plus initial values for TARGET_GLOBAL_CFLAGS
#
TARGET_ARCH_SPECIFIC_MAKEFILE := $(BUILD_COMBOS)/arch/$(TARGET_ARCH)/$(TARGET_ARCH_VARIANT).mk
ifeq ($(strip $(wildcard $(TARGET_ARCH_SPECIFIC_MAKEFILE))),)
  $(error Unknown $(TARGET_ARCH) architecture variant: $(TARGET_ARCH_VARIANT))
endif

include $(TARGET_ARCH_SPECIFIC_MAKEFILE)

TARGET_CC := $(TARGET_TOOLS_PREFIX)gcc$(HOST_EXECUTABLE_SUFFIX)
TARGET_CXX := $(TARGET_TOOLS_PREFIX)g++$(HOST_EXECUTABLE_SUFFIX)
TARGET_AR := $(TARGET_TOOLS_PREFIX)ar$(HOST_EXECUTABLE_SUFFIX)
TARGET_OBJCOPY := $(TARGET_TOOLS_PREFIX)objcopy$(HOST_EXECUTABLE_SUFFIX)
TARGET_LD := $(TARGET_TOOLS_PREFIX)ld$(HOST_EXECUTABLE_SUFFIX)
TARGET_STRIP := $(TARGET_TOOLS_PREFIX)strip$(HOST_EXECUTABLE_SUFFIX)

libc_root := bionic/libc
libm_root := bionic/libm
libstdc++_root := bionic/libstdc++
libthread_db_root := bionic/libthread_db

# Set FORCE_TARGET_DEBUGGING to "true" in your buildspec.mk
# or in your environment to gdb debugging easier.
# Don't forget to do a clean build.
ifeq ($(FORCE_TARGET_DEBUGGING),true)
  TARGET_GLOBAL_CFLAGS += -fno-omit-frame-pointer \
                          -fno-strict-aliasing
endif

# This warning causes dalvik not to build with gcc 4.6+ and -Werror.
# # We cannot turn it off blindly since the option is not available
# # in gcc-4.4.x.
ifneq ($(filter 4.6 4.6.% 4.7 4.7.% 4.8 4.8.%, $(TARGET_GCC_VERSION)),)
  TARGET_GLOBAL_CFLAGS += -Wno-unused-but-set-variable \
                          -fno-strict-volatile-bitfields \
                          -Wno-unused-parameter -Wno-unused-but-set-parameter
endif

## on some hosts, the target cross-compiler is not available so do not run this command
ifneq ($(wildcard $(TARGET_CC)),)
  # We compile with the global cflags to ensure that
  # any flags which affect libgcc are correctly taken
  # into account.
  TARGET_LIBGCC := $(shell $(TARGET_CC) $(TARGET_GLOBAL_CFLAGS) -print-libgcc-file-name)
  target_libgcov := $(shell $(TARGET_CC) $(TARGET_GLOBAL_CFLAGS) \
                    -print-file-name=libgcov.a)
endif

ifeq ($(TARGET_BUILD_VARIANT),user)
  TARGET_STRIP_COMMAND = $(TARGET_STRIP) --strip-debug $< -o $@
else
  TARGET_STRIP_COMMAND = $(TARGET_STRIP) --strip-debug $< -o $@ && \
                         $(TARGET_OBJCOPY) --add-gnu-debuglink=$< $@
endif

TARGET_NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined

# unless CUSTOM_KERNEL_HEADERS is defined, we're going to use
# symlinks located in out/ to point to the appropriate kernel
# headers. see 'config/kernel_headers.make' for more details
#
ifneq ($(CUSTOM_KERNEL_HEADERS),)
  KERNEL_HEADERS_COMMON := $(CUSTOM_KERNEL_HEADERS)
  KERNEL_HEADERS_ARCH   := $(CUSTOM_KERNEL_HEADERS)
else
  KERNEL_HEADERS_COMMON := $(libc_root)/kernel/common
  KERNEL_HEADERS_ARCH   := $(libc_root)/kernel/arch-$(TARGET_ARCH)
endif
KERNEL_HEADERS := $(KERNEL_HEADERS_COMMON) $(KERNEL_HEADERS_ARCH)

# Define FDO (Feedback Directed Optimization) options.

TARGET_FDO_CFLAGS :=
TARGET_FDO_LIB :=

ifneq ($(strip $(BUILD_FDO_INSTRUMENT)),)
  # Set BUILD_FDO_INSTRUMENT=true to turn on FDO instrumentation.
  # The profile will be generated on /data/local/tmp/profile on the device.
  TARGET_FDO_CFLAGS := -fprofile-generate=/data/local/tmp/profile -DANDROID_FDO
  TARGET_FDO_LIB := $(target_libgcov)
else
  # If BUILD_FDO_INSTRUMENT is turned off, then consider doing the FDO optimizations.
  # Set TARGET_FDO_PROFILE_PATH to set a custom profile directory for your build.
  ifeq ($(strip $(TARGET_FDO_PROFILE_PATH)),)
    TARGET_FDO_PROFILE_PATH := fdo/profiles/$(TARGET_ARCH)/$(TARGET_ARCH_VARIANT)
  else
    ifeq ($(strip $(wildcard $(TARGET_FDO_PROFILE_PATH))),)
      $(warning Custom TARGET_FDO_PROFILE_PATH supplied, but directory does not exist. Turn off FDO.)
    endif
  endif

  # If the FDO profile directory can't be found, then FDO is off.
  ifneq ($(strip $(wildcard $(TARGET_FDO_PROFILE_PATH))),)
    TARGET_FDO_CFLAGS := -fprofile-use=$(TARGET_FDO_PROFILE_PATH) -DANDROID_FDO
    TARGET_FDO_LIB := $(target_libgcov)
  endif
endif

TARGET_DEFAULT_SYSTEM_SHARED_LIBRARIES := libc libstdc++ libm

TARGET_CRTBEGIN_STATIC_O := $(TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtbegin_static.o
TARGET_CRTBEGIN_DYNAMIC_O := $(TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtbegin_dynamic.o
TARGET_CRTEND_O := $(TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtend_android.o
TARGET_CRTBEGIN_SO_O := $(TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtbegin_so.o
TARGET_CRTEND_SO_O := $(TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtend_so.o

TARGET_STRIP_MODULE := true
TARGET_CUSTOM_LD_COMMAND := true
