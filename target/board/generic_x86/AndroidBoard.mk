LOCAL_PATH := $(call my-dir)

file := $(TARGET_OUT_KEYLAYOUT)/AT_Translated_Set_2_keyboard.kl
ALL_PREBUILT += $(file)
$(file): $(LOCAL_PATH)/AT_Translated_Set_2_keyboard.kl | $(ACP)
	$(transform-prebuilt-to-target)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := AT_Translated_Set_2_keyboard.kcm
include $(BUILD_KEY_CHAR_MAP)

# install x86 generic kernel with vesa fb
ifeq ($(TARGET_PREBUILT_KERNEL),)
TARGET_PREBUILT_KERNEL := prebuilt/android-x86/kernel/kernel
endif
file := $(INSTALLED_KERNEL_TARGET)
ALL_PREBUILT += $(file)
$(file): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	$(transform-prebuilt-to-target)

target_init_rc_file := $(TARGET_ROOT_OUT)/init.rc
$(target_init_rc_file) : $(LOCAL_PATH)/init.rc | $(ACP)
	 $(transform-prebuilt-to-target)
ALL_PREBUILT += $(target_init_rc_file)

target_hw_init_rc_file := $(TARGET_ROOT_OUT)/init.generic_x86.rc
$(target_hw_init_rc_file) : $(LOCAL_PATH)/init.generic_x86.rc | $(ACP)
	$(transform-prebuilt-to-target)
ALL_PREBUILT += $(target_hw_init_rc_file)

$(INSTALLED_RAMDISK_TARGET): $(target_init_rc_file) $(target_hw_init_rc_file)
file := $(TARGET_OUT)/etc/init.generic_x86.sh
$(file) : $(LOCAL_PATH)/init.generic_x86.sh | $(ACP)
	$(transform-prebuilt-to-target)
ALL_PREBUILT += $(file)
