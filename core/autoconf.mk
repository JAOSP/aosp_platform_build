##
# LOCAL_MODULE
# CONFIG_ARGS
# PKG_BINARIES
# PKG_SHARED_LIBRARIES
# PKG_DATA_FILES

TOPDIR:=$(shell pwd)/

_ac_outputs := $(PKG_BINARIES) $(PKG_SHARED_LIBRARIES) $(PKG_DATA_FILES)
_ac_outputs :=$(strip $(_ac_outputs))
_my_prefix := $(LOCAL_MODULE)_

_ac_configure := $(LOCAL_PATH)/configure

_ac_first_module := $(word 1,$(_ac_outputs))

# $(1): binary name
# $(2): class
define _ac_init_module
$(eval include $(CLEAR_VARS))
$(eval _mod_bin:=$(1))
$(eval _mod_name:=$(_my_prefix)$(subst -,_,$(subst .,_,$(_mod_bin))))
$(eval LOCAL_MODULE:=$(_mod_name))
$(eval LOCAL_MODULE_CLASS:=$(2))
$(eval LOCAL_MODULE_STEM:=$(notdir $(_mod_bin)))
$(eval LOCAL_STRIP_MODULE:=false)

$(eval include $(BUILD_SYSTEM)/dynamic_binary.mk)
$(if $(filter-out $(_ac_first_module),$(_mod_bin)),,\
	$(eval _ac_work:=$(dir $(linked_module))work))

$(linked_module): $(_ac_work)/make_done
	$(hide) mkdir -p $(dir $(linked_module));\
	cp $(_ac_work)/$(_mod_bin) $(linked_module)

endef

$(eval $(foreach mod,$(PKG_BINARIES),$(call _ac_init_module,$(mod),EXECUTABLES)))
$(eval $(foreach mod,$(PKG_SHARED_LIBRARIES),$(call _ac_init_module,$(mod),SHARED_LIBRARIES)))

_ac_mk:= $(_ac_work)/Makefile

$(_ac_work)/make_done: $(_ac_mk)
	$(hide) make -C $(_ac_work); touch $(_ac_work)

$(_ac_mk): $(_ac_configure)
	$(hide) mkdir -p $(_ac_work); cd $(_ac_work); \
	$(TOPDIR)$(_ac_configure) $(CONFIG_ARGS)
