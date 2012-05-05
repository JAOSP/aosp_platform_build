#
# Android.mk for aprof
#

LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_FORCE_STATIC_EXECUTABLE := true

ifeq ($(TARGET_ARCH),arm)
LOCAL_CFLAGS += -DARM_SPECIFIC_HACKS
endif

LOCAL_MODULE_TAGS := eng
LOCAL_CFLAGS += -O0 -g3 -Wall
LOCAL_CFLAGS += -Wall
LOCAL_CFLAGS += -DDEBUG
LOCAL_LDFLAGS += -static

LOCAL_SRC_FILES := \
    main.cpp \
	Aprof.cpp \
	Symbol.cpp \
	SymbolTable.cpp \
	Image.cpp \
	ImageCollection.cpp \
	Options.cpp \

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/ \
	external/elfutils/libelf/

LOCAL_STATIC_LIBRARIES := libelf

LOCAL_MODULE := aprof

include $(BUILD_HOST_EXECUTABLE)
