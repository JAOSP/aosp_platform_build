PRODUCT_PACKAGES := \
    AlarmClock \
    AlarmProvider \
    Calendar \
    Camera \
    DrmProvider \
    Mms \
    Music \
    Settings \
    Sync \
    Updater \
    CalendarProvider \
    SubscribedFeedsProvider \
    SyncProvider \
    VoiceDialer

$(call inherit-product, $(SRC_TARGET_DIR)/product/core.mk)

# Overrides
PRODUCT_BRAND            := openmoko
PRODUCT_BRANDING_PARTNER := openmoko
PRODUCT_NAME             := freerunner
PRODUCT_DEVICE           := freerunner
PRODUCT_MANUFACTURER     := Openmoko

# This shouldn't be necessay. Why does this file get included for other products?
#
ifeq ($(TARGET_PRODUCT),freerunner)

ARMV4 := V4_

override TARGET_TOOLS_PREFIX := $(TOPDIR)../cross/bin/arm-eabi-

override TARGET_ARCH_CFLAGS := \
			-march=armv4t -mtune=arm920t -msoft-float -mthumb-interwork \
			-D__ARM_ARCH_4__ -D__ARM_ARCH_4T__

endif
