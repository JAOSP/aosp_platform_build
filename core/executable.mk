# We don't automatically set up rules to build executables for both
# TARGET_ARCH and TARGET_2ND_ARCH.
# By default, an executable is built for TARGET_ARCH.
# To build it for TARGET_2ND_ARCH in a 64bit product, use "LOCAL_32_BIT_ONLY := true".
# To build it for both set LOCAL_BUILD_MULTILIB := true and specify
# LOCAL_MODULE_PATH_32 and LOCAL_MODULE_PATH_64 or LOCAL_MODULE_STEM_32 and
# LOCAL_MODULE_STEM_64

ifdef LOCAL_BUILD_MULTILIB
ifeq ($(LOCAL_MODULE_PATH_32)$(LOCAL_MODULE_STEM_32),)
$(error LOCAL_MODULE_STEM_32 or LOCAL_MODULE_PATH_32 is required for LOCAL_BUILD_MULTILIB for module $(LOCAL_MODULE))
endif
ifeq ($(LOCAL_MODULE_PATH_64)$(LOCAL_MODULE_STEM_64),)
$(error LOCAL_MODULE_STEM_64 or LOCAL_MODULE_PATH_64 is required for LOCAL_BUILD_MULTILIB for module $(LOCAL_MODULE))
endif
else #!LOCAL_BUILD_MULTILIB
LOCAL_NO_2ND_ARCH_MODULE_SUFFIX := true
endif

ifeq ($(TARGET_PREFER_32_BIT),true)
ifneq ($(LOCAL_NO_2ND_ARCH),true)
LOCAL_32_BIT_ONLY := true
endif
endif


my_primary_executable_built :=

# check if primary arch is supported
include $(BUILD_SYSTEM)/module_arch_supported.mk
ifeq ($(my_module_arch_supported),true)
# primary arch is supported
include $(BUILD_SYSTEM)/executable_internal.mk
my_primary_executable_built := true
endif

# check if primary arch was not supported or asked to build both
ifneq ($(my_primary_executable_built)|$(LOCAL_BUILD_MULTILIB),true|)
ifneq (,$(TARGET_2ND_ARCH))
# check if secondary arch is supported
LOCAL_2ND_ARCH_VAR_PREFIX := $(TARGET_2ND_ARCH_VAR_PREFIX)
include $(BUILD_SYSTEM)/module_arch_supported.mk
ifeq ($(my_module_arch_supported),true)
# secondary arch is supported
OVERRIDE_BUILT_MODULE_PATH :=
LOCAL_BUILT_MODULE :=
LOCAL_INSTALLED_MODULE :=
LOCAL_MODULE_STEM :=
LOCAL_BUILT_MODULE_STEM :=
LOCAL_INSTALLED_MODULE_STEM :=
LOCAL_INTERMEDIATE_TARGETS :=
include $(BUILD_SYSTEM)/executable_internal.mk
endif
endif # TARGET_2ND_ARCH
endif # !my_primary_executable_built || LOCAL_BUILD_MULTILIB
LOCAL_2ND_ARCH_VAR_PREFIX :=
LOCAL_NO_2ND_ARCH_MODULE_SUFFIX :=

my_primary_executable_built :=
my_module_arch_supported :=
