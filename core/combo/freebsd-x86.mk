# Configuration for FreeBSD on x86.
# Included by combo/select.make

# right now we get these from the environment, but we should
# pick them from the tree somewhere
$(combo_target)CC := $(CC)
$(combo_target)CXX := $(CXX)
$(combo_target)AR := $(AR)

$(combo_target)GLOBAL_CFLAGS += -fPIC -m32 -I/usr/local/include -DOS_FREEBSD
$(combo_target)GLOBAL_CFLAGS += \
	-include $(call select-android-config-h,freebsd-x86)
$(combo_target)GLOBAL_LDFLAGS += -m32

$(combo_target)NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined

ifeq ($(combo_target),HOST_)
# $(1): The file to check
define get-file-size
stat -f %z "$(1)"
endef

# Uncomment to use gcc34 (lang/gcc34) for qemu compilation
#GCCQEMU := gcc34

endif  # HOST
