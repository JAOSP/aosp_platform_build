LOCAL_PATH := $(call my-dir)

ifneq ($(TARGET_ARCH),x86)
file := $(TARGET_OUT_KEYLAYOUT)/tuttle2.kl
ALL_PREBUILT += $(file)
$(file) : $(LOCAL_PATH)/tuttle2.kl | $(ACP)
	$(transform-prebuilt-to-target)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := tuttle2.kcm
include $(BUILD_KEY_CHAR_MAP)

else #ifneq ($(TARGET_ARCH),x86)
####################################################################

# Let's make x86 generic
file := $(TARGET_OUT_KEYLAYOUT)/AT_Translated_Set_2_keyboard.kl
ALL_PREBUILT += $(file)
$(file): $(LOCAL_PATH)/x86/AT_Translated_Set_2_keyboard.kl | $(ACP)
	$(transform-prebuilt-to-target)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := x86/AT_Translated_Set_2_keyboard.kcm
include $(BUILD_KEY_CHAR_MAP)

# install x86 generic kernel with vesa fb, so kvm image can use it
ifeq ($(TARGET_PREBUILT_KERNEL),)
TARGET_PREBUILT_KERNEL := $(LOCAL_PATH)/x86/kernel
endif
file := $(INSTALLED_KERNEL_TARGET)
ALL_PREBUILT += $(file)
$(file): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	$(transform-prebuilt-to-target)

# Lets install our own init.rc files :)
LOCAL_PATH := build/target/board/generic
include $(CLEAR_VARS)
target_init_rc_file := $(TARGET_ROOT_OUT)/init.rc
$(target_init_rc_file) : $(LOCAL_PATH)/x86/init.rc | $(ACP)
	$(transform-prebuilt-to-target)
ALL_PREBUILT += $(target_init_rc_file)

target_hw_init_rc_file := $(TARGET_ROOT_OUT)/init.generic.rc
$(target_hw_init_rc_file) : $(LOCAL_PATH)/x86/init.generic.rc | $(ACP)
	$(transform-prebuilt-to-target)
ALL_PREBUILT += $(target_hw_init_rc_file)

$(INSTALLED_RAMDISK_TARGET): $(target_init_rc_file) $(target_hw_init_rc_file)
# and our initialization script
file := $(TARGET_OUT)/etc/init.generic.sh
$(file) : $(LOCAL_PATH)/x86/init.generic.sh | $(ACP)
	$(transform-prebuilt-to-target)
ALL_PREBUILT += $(file)
endif
