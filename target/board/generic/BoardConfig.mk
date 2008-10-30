# config.mk
# 
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_ARCH := arm
TARGET_OS := linux
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true
TARGET_NO_RADIOIMAGE := true
HAVE_HTC_AUDIO_DRIVER := true
BOARD_USES_GENERIC_AUDIO := true

TARGET_GLOBAL_MACH_CFLAGS = \
			-march=armv5te -mtune=xscale \
			-msoft-float -fpic \
			-mthumb-interwork \
			-ffunction-sections \
			-funwind-tables \
			-fstack-protector \
			-D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ \
			-D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__

TARGET_CC_PREFETCH_LOOP_ARRAYS_FLAG := -fprefetch-loop-arrays
