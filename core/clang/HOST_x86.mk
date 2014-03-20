
include $(BUILD_SYSTEM)/clang/x86.mk

ifeq ($(HOST_OS),linux)
CLANG_CONFIG_x86_HOST_TRIPLE := i686-linux-gnu
endif
ifeq ($(HOST_OS),darwin)
CLANG_CONFIG_x86_HOST_TRIPLE := i686-apple-darwin
endif
ifeq ($(HOST_OS),windows)
CLANG_CONFIG_x86_HOST_TRIPLE := i686-pc-mingw32
endif

CLANG_CONFIG_x86_HOST_EXTRA_ASFLAGS := \
  $(CLANG_CONFIG_EXTRA_ASFLAGS) \
  $(CLANG_CONFIG_HOST_EXTRA_ASFLAGS) \
  $(CLANG_CONFIG_x86_EXTRA_ASFLAGS) \
  --sysroot=prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/sysroot \
  --gcc-toolchain=prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6 \
  -target $(CLANG_CONFIG_x86_HOST_TRIPLE) \
  -m32

CLANG_CONFIG_x86_HOST_EXTRA_CFLAGS := \
  $(CLANG_CONFIG_EXTRA_CFLAGS) \
  $(CLANG_CONFIG_HOST_EXTRA_CFLAGS) \
  $(CLANG_CONFIG_x86_EXTRA_CFLAGS) \
  $(CLANG_CONFIG_x86_HOST_EXTRA_ASFLAGS)

CLANG_CONFIG_x86_HOST_EXTRA_CPPFLAGS := \
  $(CLANG_CONFIG_EXTRA_CPPFLAGS) \
  $(CLANG_CONFIG_HOST_EXTRA_CPPFLAGS) \
  $(CLANG_CONFIG_x86_EXTRA_CPPFLAGS) \
  --sysroot=prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/sysroot \
  --gcc-toolchain=prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6 \
  -isystem prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/i686-linux/include/c++/4.6.x-google \
  -isystem prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/i686-linux/include/c++/4.6.x-google/i686-linux \
  -isystem prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/i686-linux/include/c++/4.6.x-google/backward \
  -m32

CLANG_CONFIG_x86_HOST_EXTRA_LDFLAGS := \
  $(CLANG_CONFIG_EXTRA_LDFLAGS) \
  $(CLANG_CONFIG_HOST_EXTRA_LDFLAGS) \
  $(CLANG_CONFIG_x86_EXTRA_LDFLAGS) \
  -target $(CLANG_CONFIG_x86_HOST_TRIPLE) \
  --sysroot=prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/sysroot \
  --gcc-toolchain=prebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6 \
  -Bprebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/i686-linux/bin \
  -Bprebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/lib/gcc/i686-linux/4.6.x-google/ \
  -Lprebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/lib/gcc/i686-linux/4.6.x-google/ \
  -Lprebuilts/gcc/$(BUILD_OS)-x86/host/i686-linux-glibc2.7-4.6/i686-linux/lib/ \
  -m32

define convert-to-host-clang-flags
  $(strip \
  $(call subst-clang-incompatible-x86-flags,\
  $(filter-out $(CLANG_CONFIG_x86_UNKNOWN_CFLAGS),\
  $(1))))
endef

CLANG_HOST_GLOBAL_CFLAGS := \
  $(call convert-to-host-clang-flags,$(HOST_GLOBAL_CFLAGS)) \
  $(CLANG_CONFIG_x86_HOST_EXTRA_CFLAGS)

CLANG_HOST_GLOBAL_CPPFLAGS := \
  $(call convert-to-host-clang-flags,$(HOST_GLOBAL_CPPFLAGS)) \
  $(CLANG_CONFIG_x86_HOST_EXTRA_CPPFLAGS)

CLANG_HOST_GLOBAL_LDFLAGS := \
  $(call convert-to-host-clang-flags,$(HOST_GLOBAL_LDFLAGS)) \
  $(CLANG_CONFIG_x86_HOST_EXTRA_LDFLAGS)
