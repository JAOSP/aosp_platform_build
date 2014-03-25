#######################################################
## Shared definitions for all target test compilations.
#######################################################

LOCAL_CFLAGS += -DGTEST_OS_LINUX_ANDROID -DGTEST_HAS_STD_STRING

LOCAL_C_INCLUDES += external/gtest/include
LOCAL_STATIC_LIBRARIES += libgtest libgtest_main

ifndef LOCAL_SDK_VERSION
LOCAL_C_INCLUDES += bionic \
                    bionic/libstdc++/include \
                    external/stlport/stlport
LOCAL_SHARED_LIBRARIES += libstlport
endif

ifdef LOCAL_MODULE_PATH
$(error Do not set LOCAL_MODULE_PATH when building tests)
endif

ifdef LOCAL_MODULE_PATH_32
$(error Do not set LOCAL_MODULE_PATH_32 when building tests)
endif

ifdef LOCAL_MODULE_PATH_64
$(error Do not set LOCAL_MODULE_PATH_64 when building tests)
endif

LOCAL_MODULE_PATH_32 := $(TARGET_OUT_DATA_NATIVE_TESTS)/$(LOCAL_MODULE)
LOCAL_MODULE_PATH_64 := $(TARGET_OUT_DATA_NATIVE_TESTS)64/$(LOCAL_MODULE)
