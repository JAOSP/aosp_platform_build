ifneq ($(TARGET_2ND_ARCH),)

# VMs - need 64-bit support
_64_bit_directory_blacklist := \
	art \
	dalvik \

# JNI - needs 64-bit VM
_64_bit_directory_blacklist += \
	external/conscrypt \
	external/neven \
	external/svox \
	libcore \
	packages \

# Chromium/V8: needs 64-bit support
_64_bit_directory_blacklist += \
	external/chromium \
	external/chromium-libpac \
	external/chromium_org \
	external/skia \
	external/v8 \
	frameworks/webview \

# misc build errors
_64_bit_directory_blacklist += \
	external/bluetooth/bluedroid \
	external/compiler-rt \
	external/llvm \
	external/oprofile/opcontrol \
	frameworks/av \
	frameworks/base \
	frameworks/compile \
	frameworks/ex \
	frameworks/ml \
	frameworks/opt \
	frameworks/rs \
	frameworks/wilhelm \
	device/generic/goldfish/opengl \
	device/generic/goldfish/camera \

# depends on frameworks/av
_64_bit_directory_blacklist += \
	hardware/libhardware_legacy/audio \
	hardware/libhardware/modules/audio_remote_submix \

_64_bit_directory_blacklist_pattern := $(addsuffix %,$(_64_bit_directory_blacklist))

define directory_is_64_bit_blacklisted
$(if $(filter $(_64_bit_directory_blacklist_pattern),$(1)),true)
endef
else
define directory_is_64_bit_blacklisted
endef
endif
