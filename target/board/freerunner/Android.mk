LOCAL_PATH := $(call my-dir)

# Keyboard layouts...

copy_from := Neo1973_Buttons.kl \
             FIC_Neo1973_PMU_events.kl \
             GTA02_PMU_events.kl

copy_to := $(addprefix $(TARGET_OUT_KEYLAYOUT)/,$(copy_from))
copy_from := $(addprefix $(LOCAL_PATH)/,$(copy_from))

$(copy_to) : $(TARGET_OUT_KEYLAYOUT)/% : $(LOCAL_PATH)/% | $(ACP)
	$(transform-prebuilt-to-target)

ALL_PREBUILT += $(copy_to)

# Build the binary keymaps...

include $(CLEAR_VARS)
LOCAL_SRC_FILES := Neo1973_Buttons.kcm
include $(BUILD_KEY_CHAR_MAP)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := FIC_Neo1973_PMU_events.kcm
include $(BUILD_KEY_CHAR_MAP)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := GTA02_PMU_events.kcm
include $(BUILD_KEY_CHAR_MAP)

##
## Use our own init.rc
##

include $(CLEAR_VARS)

file := $(TARGET_ROOT_OUT)/init.rc
$(file) : $(LOCAL_PATH)/init.rc | $(ACP)
	$(transform-prebuilt-to-target)

ALL_PREBUILT += $(file)

##
## Extra etc files
##

include $(CLEAR_VARS)

define local_find_etc_files
$(patsubst ./%,%,$(shell cd $(LOCAL_PATH)/etc ; find . -type f -printf "%P\n"))
endef

LOCAL_ETC_DIR  := $(LOCAL_PATH)/etc

copy_from := $(call local_find_etc_files)
copy_to   := $(addprefix $(TARGET_OUT_ETC)/,$(copy_from))
copy_from := $(addprefix $(LOCAL_ETC_DIR),$(copy_from))

$(copy_to) : $(TARGET_OUT_ETC)/% : $(LOCAL_ETC_DIR)/% | $(ACP)
	$(transform-prebuilt-to-target)

ALL_PREBUILT += $(copy_to)
