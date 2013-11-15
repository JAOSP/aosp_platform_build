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
DEX2OAT_DEPENDENCY := art/runtime/oat.cc # dependency on oat version number
DEX2OAT_DEPENDENCY += art/runtime/image.cc # dependency on image version number
DEX2OAT_DEPENDENCY += |
DEX2OAT_DEPENDENCY += $(DEX2OAT)
DEX2OAT_DEPENDENCY += $(LIBART_COMPILER)

DEX_PREOPT_IMAGE := /$(DEXPREOPT_BOOT_JAR_DIR)/boot.art
DEFAULT_DEX_PREOPT_IMAGE := $(PRODUCT_OUT)$(DEX_PREOPT_IMAGE)

DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES := default
ifeq ($(TARGET_CPU_VARIANT),$(filter $(TARGET_CPU_VARIANT),cortex-a15 krait))
DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES := div
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
