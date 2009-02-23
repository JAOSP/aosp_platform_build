LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_ARCH),x86)
# Let's make x86 generic
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
endif
