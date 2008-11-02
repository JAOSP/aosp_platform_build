# config.mk
# 
# Product-specific compile-time definitions.
#

BOARD_HAVE_BLUETOOTH    := true
BOARD_USES_ALSA_AUDIO	:= true
HAVE_HTC_AUDIO_DRIVER	:= false
HAVE_WEXT_WIFI_DRIVER	:= true
USE_PRODUCT_WIFI_CONF	:= true
NO_PAGE_FLIP			:= true
TARGET_NO_BOOTLOADER	:= true
TARGET_NO_KERNEL		:= true
TARGET_PROVIDES_INIT_RC	:= true
USE_CAMERA_STUB			:= true
USE_LED_TYPE			:= generic
USE_QEMU_GPS_HARDWARE	:= true
USE_SENSOR_TYPE			:= moko
USE_VIBRATOR_TYPE		:= led

# The jpeg assembly doesn't currently suport armv4t
ANDROID_JPEG_NO_ASSEMBLER	:= true

# Do not build iptables
override BUILD_IPTABLES		:= 0
