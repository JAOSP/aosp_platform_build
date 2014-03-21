# Translate LOCAL_32_BIT_ONLY and LOCAL_NO_2ND_ARCH to LOCAL_BUILD_MULTILIB,
# and check LOCAL_BUILD_MULTILIB is a valid value.  Returns module's multilib
# setting in my_module_build_multilib, or empty if not set.

my_module_build_multilib := $(strip $(LOCAL_BUILD_MULTILIB))
ifndef my_module_build_multlib
ifeq ($(LOCAL_32_BIT_ONLY)|$(LOCAL_NO_2ND_ARCH),true|true)
ifdef TARGET_2ND_ARCH
# Both LOCAL_32_BIT_ONLY and LOCAL_NO_2ND_ARCH specified on 64-bit target
# skip the module completely
my_module_build_multilib := none
else
# Both LOCAL_32_BIT_ONLY and LOCAL_NO_2ND_ARCH specified on 32-bit target
# build for 32-bit
my_module_build_multilib := 32
endif
else ifeq ($(LOCAL_32_BIT_ONLY),true)
my_module_build_multilib := 32
else ifeq ($(LOCAL_NO_2ND_ARCH),true)
my_module_build_multilib := primary
endif
else
ifeq (,$(filter $(my_module_build_multilib),32 primary both none))
$(error $(LOCAL_PATH): Invalid LOCAL_BUILD_MULTILIB specified for module $(LOCAL_MODULE))
endif
endif
