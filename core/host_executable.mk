###########################################################
## Standard rules for building an executable file.
##
## Additional inputs from base_rules.make:
## None.
###########################################################

ifeq ($(or $(USE_CLANG),$(USE_HOST_CLANG)),1)
  include $(BUILD_SYSTEM)/use_clang.mk
endif

LOCAL_IS_HOST_MODULE := true
ifeq ($(strip $(LOCAL_MODULE_CLASS)),)
LOCAL_MODULE_CLASS := EXECUTABLES
endif
ifeq ($(strip $(LOCAL_MODULE_SUFFIX)),)
LOCAL_MODULE_SUFFIX := $(HOST_EXECUTABLE_SUFFIX)
endif

include $(BUILD_SYSTEM)/binary.mk

$(LOCAL_BUILT_MODULE): $(all_objects) $(all_libraries)
	$(transform-host-o-to-executable)
	$(PRIVATE_POST_PROCESS_COMMAND)

ifeq ($(or $(USE_CLANG),$(USE_HOST_CLANG)),1)
  include $(BUILD_SYSTEM)/restore_compiler.mk
endif
