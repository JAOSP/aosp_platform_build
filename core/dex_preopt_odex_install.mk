# dexpreopt_odex_install.mk is used to define odex creation rules for JARs and APKs

# Setting LOCAL_DEX_PREOPT based on WITH_DEXPREOPT, LOCAL_DEX_PREOPT, etc
LOCAL_DEX_PREOPT := $(strip $(LOCAL_DEX_PREOPT))
ifneq (true,$(WITH_DEXPREOPT))
  LOCAL_DEX_PREOPT :=
else # WITH_DEXPREOPT=true
  ifeq (,$(TARGET_BUILD_APPS)) # TARGET_BUILD_APPS empty
    ifneq (,$(LOCAL_SRC_FILES)) # LOCAL_SRC_FILES not empty
      ifndef LOCAL_DEX_PREOPT # LOCAL_DEX_PREOPT undefined
        ifeq (,$(LOCAL_APK_LIBRARIES)) # LOCAL_APK_LIBRARIES empty
          LOCAL_DEX_PREOPT := $(DEX_PREOPT_DEFAULT)
        else # LOCAL_APK_LIBRARIES not empty
          LOCAL_DEX_PREOPT := nostripping
        endif # LOCAL_APK_LIBRARIES not empty
      endif # LOCAL_DEX_PREOPT undefined
    endif # LOCAL_SRC_FILES not empty
  endif # TARGET_BUILD_APPS empty
endif # WITH_DEXPREOPT=true
ifeq (false,$(LOCAL_DEX_PREOPT))
  LOCAL_DEX_PREOPT :=
endif

ifndef LOCAL_UNINSTALLABLE_MODULE
dexpreopt_boot_jar_module := $(filter $(LOCAL_MODULE),$(DEXPREOPT_BOOT_JARS_MODULES))
built_odex := $(basename $(LOCAL_BUILT_MODULE)).odex
ifeq ($(dexpreopt_boot_jar_module),) # not boot jar
ifdef LOCAL_DEX_PREOPT
# if module oat file requested in data, disable LOCAL_DEX_PREOPT, will default location to dalvik-cache
ifneq (,$(filter $(LOCAL_MODULE),$(PRODUCT_DEX_PREOPT_PACKAGES_IN_DATA)))
LOCAL_DEX_PREOPT :=
endif
endif # LOCAL_DEX_PREOPT
ifdef LOCAL_DEX_PREOPT
installed_odex := $(basename $(LOCAL_INSTALLED_MODULE)).odex
endif # LOCAL_DEX_PREOPT
ifneq (,$(strip $(all_java_sources)$(full_static_java_libs)$(my_prebuilt_src_file))) # contains java code
ifneq (,$(LOCAL_DEX_PREOPT))
$(installed_odex) : $(built_odex) | $(ACP)
	@echo "Install: $@"
	$(copy-file-to-target)

# Add the installed_odex to the list of installed files for this module.
ALL_MODULES.$(LOCAL_MODULE).INSTALLED := \
    $(ALL_MODULES.$(LOCAL_MODULE).INSTALLED) $(installed_odex)
endif # non-empty LOCAL_DEX_PREOPT
endif # contains java code
endif # not boot jar

ifeq ($(LOCAL_DEX_PREOPT_IMAGE),)
LOCAL_DEX_PREOPT_IMAGE := $(DEFAULT_DEX_PREOPT_IMAGE)
endif # LOCAL_DEX_PREOPT_IMAGE

endif # !LOCAL_UNINSTALLABLE_MODULE
