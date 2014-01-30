# We don't automatically set up rules to build executables for both
# TARGET_ARCH and TARGET_2ND_ARCH.
# By default, an executable is built for TARGET_ARCH.
# To build it for TARGET_2ND_ARCH in a 64bit product, use "LOCAL_32_BIT_ONLY := true".

LOCAL_2ND_ARCH_VAR_PREFIX :=
ifeq ($(TARGET_IS_64_BIT),true)
ifeq ($(LOCAL_32_BIT_ONLY),true)
LOCAL_2ND_ARCH_VAR_PREFIX := $(TARGET_2ND_ARCH_VAR_PREFIX)
else ifeq ($(BUILD_PREFER_32_BIT)|$(LOCAL_NO_2ND_ARCH),true|)
LOCAL_2ND_ARCH_VAR_PREFIX := $(TARGET_2ND_ARCH_VAR_PREFIX)
endif
endif

include $(BUILD_SYSTEM)/executable_internal.mk
LOCAL_2ND_ARCH_VAR_PREFIX :=
