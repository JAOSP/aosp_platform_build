####################################
# dexpreopt support - typically used on user builds to run dexopt (for Dalvik) or dex2oat (for ART) ahead of time
#
####################################

# Extract out the default runtime value.
product_property_overrides_dalvik_vm_lib := $(strip \
    $(patsubst persist.sys.dalvik.vm.lib=%,%,\
    $(filter persist.sys.dalvik.vm.lib=%,$(PRODUCT_PROPERTY_OVERRIDES))))
ifeq ($(product_property_overrides_dalvik_vm_lib),)
$(error No value for persist.sys.dalvik.vm.lib in PRODUCT_PROPERTY_OVERRIDES)
endif

# list of boot classpath jars for dexpreopt
DEXPREOPT_BOOT_JARS := $(PRODUCT_BOOT_JARS)
DEXPREOPT_BOOT_JARS_MODULES := $(subst :, ,$(DEXPREOPT_BOOT_JARS))
PRODUCT_BOOTCLASSPATH := $(subst $(space),:,$(foreach m,$(DEXPREOPT_BOOT_JARS_MODULES),/system/framework/$(m).jar))

DEXPREOPT_BUILD_DIR := $(OUT_DIR)
DEXPREOPT_PRODUCT_DIR := $(patsubst $(DEXPREOPT_BUILD_DIR)/%,%,$(PRODUCT_OUT))/dex_bootjars
DEXPREOPT_BOOT_JAR_DIR := system/framework
DEXPREOPT_BOOT_JAR_DIR_FULL_PATH := $(DEXPREOPT_BUILD_DIR)/$(DEXPREOPT_PRODUCT_DIR)/$(DEXPREOPT_BOOT_JAR_DIR)

# $(1): the .jar or .apk to remove classes.dex
define dexpreopt-remove-classes.dex
$(hide) $(AAPT) remove $(1) classes.dex
endef

# Special rules for building stripped boot jars that override java_library.mk rules

# $(1): boot jar module name
define _dexpreopt-boot-jar
$(eval _dbj_jar_no_dex := $(DEXPREOPT_BOOT_JAR_DIR_FULL_PATH)/$(1)_nodex.jar)
$(eval _dbj_src_jar := $(call intermediates-dir-for,JAVA_LIBRARIES,$(1),,COMMON)/javalib.jar)

$(_dbj_jar_no_dex) : $(_dbj_src_jar) | $(ACP) $(AAPT)
	$$(call copy-file-to-target)
ifneq ($(DEX_PREOPT_DEFAULT),nostripping)
	$$(call dexpreopt-remove-classes.dex,$$@)
endif

$(eval _dbj_jar_no_dex :=)
$(eval _dbj_src_jar :=)
endef

$(foreach b,$(DEXPREOPT_BOOT_JARS_MODULES),$(eval $(call _dexpreopt-boot-jar,$(b))))

# Conditionally include Dalvik support.
ifeq ($(product_property_overrides_dalvik_vm_lib),libdvm.so)
include $(BUILD_SYSTEM)/dex_preopt_libdvm.mk
endif

# Unconditionally include ART support because its used run dex2oat on the host for tests.
include $(BUILD_SYSTEM)/dex_preopt_libart.mk

# Define dexpreopt-one-file based on current default runtime.
ifeq ($(product_property_overrides_dalvik_vm_lib),libdvm.so)
define dexpreopt-one-file
$(call dexopt-one-file,$(2),$(4))
endef
else
define dexpreopt-one-file
$(call dex2oat-one-file,$(1),$(2),$(3),$(4))
endef
endif

# dexpreopt-odex-install is used to define odex creation rules for JARs and APKs
# $(1): true if prebuilt, empty otherwise
define dexpreopt-odex-install

# Setting LOCAL_DEX_PREOPT based on WITH_DEXPREOPT, LOCAL_DEX_PREOPT, etc
LOCAL_DEX_PREOPT := $$(strip $$(LOCAL_DEX_PREOPT))
ifneq (true,$$(WITH_DEXPREOPT))
  LOCAL_DEX_PREOPT :=
else # WITH_DEXPREOPT=true
  ifeq (,$$(TARGET_BUILD_APPS)) # TARGET_BUILD_APPS empty
    ifneq (,$(LOCAL_SRC_FILES)) # LOCAL_SRC_FILES not empty
      ifndef LOCAL_DEX_PREOPT # LOCAL_DEX_PREOPT undefined
        ifeq ($$(user_variant),user) # user build
          ifeq (,$$(LOCAL_APK_LIBRARIES)) # LOCAL_APK_LIBRARIES empty
            LOCAL_DEX_PREOPT := $(DEX_PREOPT_DEFAULT)
          else # LOCAL_APK_LIBRARIES not empty
            LOCAL_DEX_PREOPT := nostripping
          endif # LOCAL_APK_LIBRARIES not empty
        else # not user build
          ifeq ($$(WITH_HOST_DALVIK),true) # WITH_HOST_DALVIK=true
            LOCAL_DEX_PREOPT := nostripping
          else # WITH_HOST_DALVIK not true
            LOCAL_DEX_PREOPT :=
          endif # WITH_HOST_DALVIK not true
        endif # not user build
      endif # LOCAL_DEX_PREOPT undefined
    endif # LOCAL_SRC_FILES not empty
  endif # TARGET_BUILD_APPS empty
endif # WITH_DEXPREOPT=true
ifeq (false,$$(LOCAL_DEX_PREOPT))
  LOCAL_DEX_PREOPT :=
endif

ifndef LOCAL_UNINSTALLABLE_MODULE
dexpreopt_boot_jar_module := $$(filter $$(LOCAL_MODULE),$$(DEXPREOPT_BOOT_JARS_MODULES))
built_odex := $$(basename $$(LOCAL_BUILT_MODULE)).odex
ifeq ($$(dexpreopt_boot_jar_module),) # not boot jar
ifdef LOCAL_DEX_PREOPT
# if module oat file requested in data, disable LOCAL_DEX_PREOPT, will default location to dalvik-cache
ifneq (,$$(filter $$(LOCAL_MODULE),$$(PRODUCT_DEX_PREOPT_PACKAGES_IN_DATA)))
LOCAL_DEX_PREOPT :=
endif
endif # LOCAL_DEX_PREOPT
ifdef LOCAL_DEX_PREOPT
installed_odex := $$(basename $$(LOCAL_INSTALLED_MODULE)).odex
else # !LOCAL_DEX_PREOPT
installed_odex := $$(call dalvik-cache-out,$$(subst $$(PRODUCT_OUT)/,,$$(basename $$(LOCAL_INSTALLED_MODULE)).odex))
endif # !LOCAL_DEX_PREOPT
ifneq (,$$(strip $$(all_java_sources)$$(full_static_java_libs)$(1))) # contains java code
ifneq (,$$(LOCAL_DEX_PREOPT))
$$(installed_odex) : $$(built_odex) | $$(ACP)
	@echo "Install: $$@"
	$$(copy-file-to-target)

$$(LOCAL_INSTALLED_MODULE) : $$(installed_odex)

# Add the installed_odex to the list of installed files for this
# module to ensure that INTERNAL_USERDATAIMAGE_FILES includes
# dalvik-cache files in userdata.img.
ALL_MODULES.$$(LOCAL_MODULE).INSTALLED := \
    $$(ALL_MODULES.$$(LOCAL_MODULE).INSTALLED) $$(installed_odex)
endif # non-empty LOCAL_DEX_PREOPT
endif # contains java code
endif # not boot jar

ifeq ($$(LOCAL_DEX_PREOPT_IMAGE),)
LOCAL_DEX_PREOPT_IMAGE := $$(DEFAULT_DEX_PREOPT_IMAGE)
endif # LOCAL_DEX_PREOPT_IMAGE

endif # !LOCAL_UNINSTALLABLE_MODULE

endef # dexpreopt-odex-install
