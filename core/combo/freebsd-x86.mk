# Configuration for Linux on x86.
# Included by combo/select.make

# right now we get these from the environment, but we should
# pick them from the tree somewhere
$(combo_target)CC := $(CC)
$(combo_target)CXX := $(CXX)
$(combo_target)AR := $(AR)

ifeq ($(combo_target),HOST_)
# $(1): The file to check
define get-file-size
stat --format "%s" "$(1)" | tr -d '\n'
endef
endif

# On the sim, we build the "host" tools in 64 bit iff the compiler
# does it for us automatically.  In other words, that means on 64 bit
# system, they're 64 bit and on 32 bit systems, they're 32 bits.  In
# all other cases, we build 32 bit, since this is what we release.
ifneq ($(combo_target)$(TARGET_SIMULATOR),HOST_true)
$(combo_target)GLOBAL_CFLAGS := $($(combo_target)GLOBAL_CFLAGS) -m32
$(combo_target)GLOBAL_LDFLAGS := $($(combo_target)GLOBAL_LDFLAGS) -m32
endif


$(combo_target)GLOBAL_CFLAGS += -fPIC
$(combo_target)GLOBAL_CFLAGS += \
	-include $(call select-android-config-h,freebsd-x86)

$(combo_target)NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined

ANDROID_JAVA_HOME=/usr/local/diablo-jdk1.5.0/

TARGET_TOOLS_PREFIX:=prebuilt/$(HOST_PREBUILT_TAG)/toolchain/arm-eabi-4.4.0/bin/arm-unknown-eabi-
