
include $(BUILD_SYSTEM)/clang/x86_64.mk

ifeq ($(HOST_OS),linux)
CLANG_CONFIG_x86_64_HOST_TRIPLE := x86_64-linux-gnu
endif
ifeq ($(HOST_OS),darwin)
CLANG_CONFIG_x86_64_HOST_TRIPLE := x86_64-apple-darwin
endif
ifeq ($(HOST_OS),windows)
CLANG_CONFIG_x86_64_HOST_TRIPLE := x86_64-pc-mingw64
endif

CLANG_CONFIG_x86_64_HOST_EXTRA_ASFLAGS := \
  $(CLANG_CONFIG_EXTRA_ASFLAGS) \
  $(CLANG_CONFIG_HOST_EXTRA_ASFLAGS) \
  $(CLANG_CONFIG_x86_64_EXTRA_ASFLAGS) \
  -target $(CLANG_CONFIG_x86_64_HOST_TRIPLE) \
  --sysroot=prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/sysroot \
  --gcc-toolchain=prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6 \
  -target $(CLANG_CONFIG_x86_HOST_TRIPLE) \
  -m64

CLANG_CONFIG_x86_64_HOST_EXTRA_CFLAGS := \
  $(CLANG_CONFIG_EXTRA_CFLAGS) \
  $(CLANG_CONFIG_HOST_EXTRA_CFLAGS) \
  $(CLANG_CONFIG_x86_64_EXTRA_CFLAGS) \
  $(CLANG_CONFIG_x86_64_HOST_EXTRA_ASFLAGS)

CLANG_CONFIG_x86_64_HOST_EXTRA_CPPFLAGS := \
  $(CLANG_CONFIG_EXTRA_CPPFLAGS) \
  $(CLANG_CONFIG_HOST_EXTRA_CPPFLAGS) \
  $(CLANG_CONFIG_x86_64_EXTRA_CPPFLAGS) \
  --sysroot=prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/sysroot \
  --gcc-toolchain=prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6 \
  -isystem prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/x86_64-linux/include/c++/4.6.x-google \
  -isystem prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/x86_64-linux/include/c++/4.6.x-google/x86_64-linux \
  -isystem prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/x86_64-linux/include/c++/4.6.x-google/backward \
  -m64


CLANG_CONFIG_x86_64_HOST_EXTRA_LDFLAGS := \
  $(CLANG_CONFIG_EXTRA_LDFLAGS) \
  $(CLANG_CONFIG_HOST_EXTRA_LDFLAGS) \
  $(CLANG_CONFIG_x86_64_EXTRA_LDFLAGS) \
  -target $(CLANG_CONFIG_x86_64_HOST_TRIPLE) \
  --sysroot=prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/sysroot \
  --gcc-toolchain=prebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6 \
  -Bprebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/x86_64-linux/bin \
  -Bprebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/lib/gcc/x86_64-linux/4.6.x-google/ \
  -Lprebuilts/gcc/$(BUILD_OS)-x86/host/x86_64-linux-glibc2.7-4.6/x86_64-linux/lib/ \
  -m64

define convert-to-host-clang-flags
  $(strip \
  $(call subst-clang-incompatible-x86_64-flags,\
  $(filter-out $(CLANG_CONFIG_x86_64_UNKNOWN_CFLAGS),\
  $(1))))
endef

CLANG_HOST_GLOBAL_CFLAGS := \
  $(call convert-to-host-clang-flags,$(HOST_GLOBAL_CFLAGS)) \
  $(CLANG_CONFIG_x86_64_HOST_EXTRA_CFLAGS)

CLANG_HOST_GLOBAL_CPPFLAGS := \
  $(call convert-to-host-clang-flags,$(HOST_GLOBAL_CPPFLAGS)) \
  $(CLANG_CONFIG_x86_64_HOST_EXTRA_CPPFLAGS)

CLANG_HOST_GLOBAL_LDFLAGS := \
  $(call convert-to-host-clang-flags,$(HOST_GLOBAL_LDFLAGS)) \
  $(CLANG_CONFIG_x86_64_HOST_EXTRA_LDFLAGS)
