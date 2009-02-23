# config.mk
# 
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
ifeq ($(TARGET_ARCH),x86)
TARGET_COMPRESS_MODULE_SYMBOLS := false
TARGET_PRELINK_MODULE := false
TARGET_NO_RECOVERY := true
TARGET_HARDWARE_3D := false
BOARD_USES_GENERIC_AUDIO := true
USE_CUSTOM_RUNTIME_HEAP_MAX := "128M"
TARGET_USERIMAGES_USE_EXT2 := true
TARGET_BOOTIMAGE_USE_EXT2 := true
TARGET_USE_DISKINSTALLER := true
TARGET_DISK_LAYOUT_CONFIG := build/target/board/generic/x86/disk_layout.conf
BOARD_KERNEL_CMDLINE := console=tty0 console=ttyS1,115200n8 console=tty0 androidboot.hardware=x86_generic vga=788
BOARD_BOOTIMAGE_MAX_SIZE := 8388608
else #($(TARGET_ARCH),x86)
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true
TARGET_NO_RADIOIMAGE := true
HAVE_HTC_AUDIO_DRIVER := true
BOARD_USES_GENERIC_AUDIO := true
endif
