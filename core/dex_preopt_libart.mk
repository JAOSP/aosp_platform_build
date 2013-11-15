####################################
# dexpreopt support for ART
#
####################################

DEX2OAT := $(HOST_OUT_EXECUTABLES)/dex2oat$(HOST_EXECUTABLE_SUFFIX)
DEX2OATD := $(HOST_OUT_EXECUTABLES)/dex2oatd$(HOST_EXECUTABLE_SUFFIX)

LIBART_COMPILER := $(HOST_OUT_SHARED_LIBRARIES)/libart-compiler$(HOST_SHLIB_SUFFIX)
LIBARTD_COMPILER := $(HOST_OUT_SHARED_LIBRARIES)/libartd-compiler$(HOST_SHLIB_SUFFIX)

# TODO: for now, override with debug version for better error reporting
DEX2OAT := $(DEX2OATD)
LIBART_COMPILER := $(LIBARTD_COMPILER)

# By default, do not run rerun dex2oat if the tool changes.
# Comment out the | to force dex2oat to rerun on after all changes.
DEX2OAT_DEPENDENCY := |
DEX2OAT_DEPENDENCY += $(DEX2OAT)
DEX2OAT_DEPENDENCY += $(LIBART_COMPILER)

PRELOADED_CLASSES := frameworks/base/preloaded-classes

# dalvik-cache
DALVIK_CACHE_DIR := /data/dalvik-cache
DALVIK_CACHE_OUT := $(TARGET_OUT_DATA)/dalvik-cache

# $(1): pathname
define dalvik-cache-dir
$(DALVIK_CACHE_DIR)/$(subst /,@,$(1))
endef

# $(1): pathname
define dalvik-cache-out
$(DALVIK_CACHE_OUT)/$(subst /,@,$(1))
endef

ifeq ($(PRODUCT_DEX_PREOPT_IMAGE_IN_DATA),true)
DEX_PREOPT_IMAGE := $(call dalvik-cache-dir,$(DEXPREOPT_BOOT_JAR_DIR)/boot.art)
else
DEX_PREOPT_IMAGE := /$(DEXPREOPT_BOOT_JAR_DIR)/boot.art
endif
DEFAULT_DEX_PREOPT_IMAGE := $(PRODUCT_OUT)$(DEX_PREOPT_IMAGE)

DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES := default
ifeq ($(TARGET_CPU_VARIANT),$(filter $(TARGET_CPU_VARIANT),cortex-a15 krait))
DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES := div
endif

# start of image reserved address space
IMG_HOST_BASE_ADDRESS   := 0x60000000

ifeq ($(TARGET_ARCH),mips)
IMG_TARGET_BASE_ADDRESS := 0x30000000
else
IMG_TARGET_BASE_ADDRESS := 0x60000000
endif

########################################################################
# The full system boot classpath
TARGET_BOOT_JARS := $(subst :, ,$(DEXPREOPT_BOOT_JARS))
TARGET_BOOT_JARS := $(foreach jar,$(TARGET_BOOT_JARS),$(patsubst core, core-libart,$(jar)))
TARGET_BOOT_DEX_LOCATIONS := $(foreach jar,$(TARGET_BOOT_JARS),/$(DEXPREOPT_BOOT_JAR_DIR)/$(jar).jar)
TARGET_BOOT_DEX_FILES := $(foreach jar,$(TARGET_BOOT_JARS),$(call intermediates-dir-for,JAVA_LIBRARIES,$(jar),,COMMON)/javalib.jar)

TARGET_BOOT_IMG_OUT := $(DEFAULT_DEX_PREOPT_IMAGE)
TARGET_BOOT_OAT_OUT := $(patsubst %.art,%.oat,$(TARGET_BOOT_IMG_OUT))
TARGET_BOOT_OAT := $(subst $(PRODUCT_OUT),,$(TARGET_BOOT_OAT_OUT))
TARGET_BOOT_OAT_UNSTRIPPED_OUT := $(TARGET_OUT_UNSTRIPPED)$(TARGET_BOOT_OAT)

$(TARGET_BOOT_IMG_OUT): $(TARGET_BOOT_DEX_FILES) $(DEX2OAT_DEPENDENCY)
	@echo "target dex2oat: $@ ($?)"
	@mkdir -p $(dir $@)
	@mkdir -p $(dir $(TARGET_BOOT_OAT_UNSTRIPPED_OUT))
	$(hide) $(DEX2OAT) $(PARALLEL_ART_COMPILE_JOBS) --runtime-arg -Xms256m --runtime-arg -Xmx256m --image-classes=$(PRELOADED_CLASSES) $(addprefix --dex-file=,$(TARGET_BOOT_DEX_FILES)) $(addprefix --dex-location=,$(TARGET_BOOT_DEX_LOCATIONS)) \
		--oat-symbols=$(TARGET_BOOT_OAT_UNSTRIPPED_OUT) --oat-file=$(TARGET_BOOT_OAT_OUT) \
		--oat-location=$(TARGET_BOOT_OAT) --image=$(TARGET_BOOT_IMG_OUT) --base=$(IMG_TARGET_BASE_ADDRESS) \
		--instruction-set=$(TARGET_ARCH) --instruction-set-features=$(TARGET_INSTRUCTION_SET_FEATURES) --host-prefix=$(PRODUCT_OUT) --android-root=$(PRODUCT_OUT)/system

$(TARGET_BOOT_OAT_UNSTRIPPED_OUT): $(TARGET_BOOT_IMG_OUT)

$(TARGET_BOOT_OAT_OUT): $(TARGET_BOOT_OAT_UNSTRIPPED_OUT)

ifeq ($(ART_BUILD_TARGET_NDEBUG),true)
include $(CLEAR_VARS)
LOCAL_MODULE := boot.art
LOCAL_MODULE_TAGS := optional
LOCAL_ADDITIONAL_DEPENDENCIES := art/build/Android.common.mk
LOCAL_ADDITIONAL_DEPENDENCIES += art/build/Android.oat.mk
LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_BOOT_IMG_OUT) $(TARGET_BOOT_OAT_OUT)
include $(BUILD_PHONY_PACKAGE)
endif

########################################################################
# For a single jar or APK

# $(1): the boot image to use
# $(2): the input .jar or .apk file
# $(3): the input .jar or .apk target location
# $(4): the output .odex file
define dex2oat-one-file
$(hide) rm -f $(4)
$(hide) mkdir -p $(dir $(4))
$(hide) $(DEX2OAT) \
	--runtime-arg -Xms64m --runtime-arg -Xmx64m \
	--boot-image=$(1) \
	--dex-file=$(2) \
	--dex-location=$(3) \
	--oat-file=$(4) \
	--host-prefix=$(PRODUCT_OUT) \
	--android-root=$(PRODUCT_OUT)/system \
	--instruction-set=$(TARGET_ARCH) \
	--instruction-set-features=$(DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES)
endef
