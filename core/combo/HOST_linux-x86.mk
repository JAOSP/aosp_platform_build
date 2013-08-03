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

# Configuration for builds hosted on linux-x86.
# Included by combo/select.mk

# $(1): The file to check
define get-file-size
stat --format "%s" "$(1)" | tr -d '\n'
endef

# Previously the prebiult host toolchain is used only for the sdk build,
# that's why we have "sdk" in the path name.
ifeq ($(strip $(HOST_TOOLCHAIN_PREFIX)),)
HOST_TOOLCHAIN_PREFIX := prebuilts/tools/gcc-sdk
endif
# Don't do anything if the toolchain is not there
ifneq (,$(strip $(wildcard $(HOST_TOOLCHAIN_PREFIX)/gcc)))
HOST_CC  := $(HOST_TOOLCHAIN_PREFIX)/gcc
HOST_CXX := $(HOST_TOOLCHAIN_PREFIX)/g++
HOST_AR  := $(HOST_TOOLCHAIN_PREFIX)/ar
endif # $(HOST_TOOLCHAIN_PREFIX)/gcc exists

ifneq ($(strip $(BUILD_HOST_64bit)),)
# By default we build everything in 32-bit, because it gives us
# more consistency between the host tools and the target.
# BUILD_HOST_64bit=1 overrides it for tool like emulator
# which can benefit from 64-bit host arch.
HOST_GLOBAL_CFLAGS += -m64
HOST_GLOBAL_LDFLAGS += -m64
else
# We expect SSE3 floating point math.
HOST_GLOBAL_CFLAGS += -mstackrealign -msse3 -mfpmath=sse -m32
HOST_GLOBAL_LDFLAGS += -m32
endif # BUILD_HOST_64bit

ifeq ($(strip $(HOST_TOOLCHAIN_LIB_ROOT)),)
  HOST_TOOLCHAIN_LIB_ROOT := prebuilts/gcc/linux-x86/host/i686-linux-glibc2.7-4.6/lib
endif

ifneq ($(strip $(BUILD_HOST_static)),)
# Statically-linked binaries are desirable for sandboxed environment
HOST_GLOBAL_LDFLAGS += -static
endif # BUILD_HOST_static

HOST_GLOBAL_CFLAGS += -fPIC \
    -include $(call select-android-config-h,linux-x86)

# Disable new longjmp in glibc 2.11 and later. See bug 2967937.
HOST_GLOBAL_CFLAGS += -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0

HOST_NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined

host_libgcov := $(HOST_TOOLCHAIN_LIB_ROOT)/gcc/i686-linux/4.6.x-google/libgcov.a

# Define host FDO (Feedback Directed Optimization) options.

HOST_FDO_CFLAGS:=
HOST_FDO_LIB:=

ifneq ($(strip $(BUILD_HOST_FDO_INSTRUMENT)),)
  # Set BUILD_HOST_FDO_INSTRUMENT to turn on FDO instrumentation.
  # The profile will be generated in $(ANDROID_HOST_OUT)/profile by default.
  # Set HOST_FDO_PROFILE_GEN_PATH to an alternate profile
  # generation path if preferred.
  ifeq ($(strip $(HOST_FDO_PROFILE_GEN_PATH)),)
    HOST_FDO_PROFILE_GEN_PATH := $(ANDROID_HOST_OUT)/profile
  endif
  HOST_FDO_CFLAGS := -fprofile-generate=$(HOST_FDO_PROFILE_GEN_PATH)
  HOST_FDO_LIB := $(host_libgcov)
else
  # If BUILD_FDO_INSTRUMENT is turned off, then consider doing the FDO optimizations.
  # Set HOST_FDO_PROFILE_PATH to set a custom profile directory for your build.
  ifeq ($(strip $(TARGET_FDO_PROFILE_PATH)),)
    HOST_FDO_PROFILE_PATH := fdo/profiles/host/$(HOST_ARCH)
  else
    ifeq ($(strip $(wildcard $(HOST_FDO_PROFILE_PATH))),)
      $(warning Custom HOST_FDO_PROFILE_PATH supplied, but directory does not exist. Turn off FDO.)
    endif
  endif

  # If the FDO profile directory can't be found, then FDO is off.
  ifneq ($(strip $(wildcard $(HOST_FDO_PROFILE_PATH))),)
    HOST_FDO_CFLAGS := -fprofile-use=$(HOST_FDO_PROFILE_PATH)
    HOST_FDO_LIB := $(host_libgcov)
  endif
endif
