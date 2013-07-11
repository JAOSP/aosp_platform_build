#
# Copyright (C) 2013 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


MIXIN_GROUPS :=
MIXIN_GROUPS_SELECTED :=

# 'mixindebug' is a modifier Make goal which prints out additional debugging
# information about what this mechanism is actually doing. It doesn't actually
# change the build output.
.PHONY: mixindebug
mixindebug:
	@echo >/dev/null

MIXIN_DEBUG := $(filter mixindebug,$(MAKECMDGOALS))


# Debug/informational macros. Don't use commas in the messages. $(call ...)
# will use them even if quoted or escaped.
define mixin-debug
$(if $(MIXIN_DEBUG),$(warning Mixin: $(strip $(1))))
endef


define mixin-warning
$(if $(CALLED_FROM_SETUP),,$(warning Mixin: $(strip $(1))))
endef


define mixin-error
$(error Mixin: $(strip $(1))))
endef


# Add a base directory for mixin definitions. The structure must conform to:
# basedir/group1/
# basedir/groyp1/option1/
# basedir/group1/option1/product.mk, init.rc, BoardConfig.mk, etc
# basedir/group1/option2/
# (optional) basedir/group1/default symlink to a default option, used if the
#                                   product doesn't make specification
# basedir/group2/
# basedir/group2/option1/
# ....
#
# Appropriate calls to declare-mixin are made based on the structure found.
# This should be called at the top of a product Makefile before any specific
# mix-ins are inherited.
define add-mixin-basedir
$(if,,\
    $(eval _groups := $(shell ls -d -- $(strip $(1))/*)) \
    $(foreach group_path,$(_groups), \
        $(eval _group := $(notdir $(group_path))) \
        $(eval _opts_paths := $(shell ls -d -- $(group_path)/*)) \
        $(call mixin-debug, Found group $(_group) at $(group_path)) \
        $(eval _opts :=) \
        $(foreach opt_path,$(_opts_paths), \
            $(eval _opts += $(notdir $(opt_path))) \
        ) \
        $(call declare-mixin, $(_group),$(_opts),$(group_path)) \
        $(eval _opts :=) \
        $(eval _group :=) \
        $(eval _opts_paths :=) \
    ) \
)
endef


# Declare a mixin group with a set of options rooted at a particular directory,
# For every option, assumes that the supporting files for it are in
# <group base directory>/<option name>.
#
# Multiple invocations can be used to create a group whose options are a superset
# of all the individual invocations; a warning is printed if the same option is
# declared more than once, with the last definition taking precedence.
#
# Parameters
# 1 Name of the mixin group
# 2 Valid options for this mixin group
# 3 Base path for options specified
# Can be called multiple times
define declare-mixin
$(if,,\
    $(eval _name := $(strip $(1))) \
    $(eval _opts := $(strip $(2))) \
    $(eval _path := $(strip $(3))) \
    $(eval MIXIN_GROUPS := $(filter-out $(_name),$(MIXIN_GROUPS)) $(_name)) \
    $(foreach opt,$(_opts), \
        $(if $(filter $(opt),$(MIXIN_GROUP.$(_name).options)), \
            $(call mixin-warning, Overriding existing option $(opt) for $(_name) mixin) \
        , \
            $(eval MIXIN_GROUP.$(_name).options += $(opt)) \
        ) \
        $(eval _optpath := $(_path)/$(opt)) \
        $(call mixin-debug, Declared mixin $(_name).$(opt) at $(_optpath)) \
        $(eval MIXIN_GROUP.$(_name).option.$(opt) := $(_optpath)) \
        $(eval _optpath :=) \
    ) \
    $(eval _name :=) \
    $(eval _opts :=) \
    $(eval _path :=) \
)
endef


# Call this from a product Makefile to select options for each mixin.
# Every mixin in the namespace must have one option selected; this is enforced
# by check-mixin-selections. An option 'default' (typically a symlink to another
# option) is a special case; used if no explicit call to inherit-mixin is made.
#
# Parameters:
# $(1) Group name
# $(2) Selected option for that group
# Can be called multiple times, but multiple invocations for the same
# group are ignored.
define inherit-mixin
$(if,,\
    $(eval _group := $(strip $(1))) \
    $(eval _opt := $(strip $(2))) \
    $(if $(filter $(_group),$(MIXIN_GROUPS_SELECTED)),, \
        $(call mixin-debug, Selected mixin $(_opt) from group $(_group)) \
        $(if $(filter $(_group),$(MIXIN_GROUPS)), \
            $(if $(filter $(_opt),$(MIXIN_GROUP.$(_group).options)), \
                $(eval MIXIN_GROUPS_SELECTED += $(_group)) \
                $(eval MIXIN_GROUP.$(_group).selection := $(_opt)) \
                $(eval MIXIN_GROUP.$(_group).dir := $(MIXIN_GROUP.$(_group).option.$(_opt))) \
                $(eval _product_mk := $(MIXIN_GROUP.$(_group).dir)/product.mk) \
                $(if $(wildcard $(_product_mk)), \
                    $(call mixin-debug, Reading $(_product_mk)) \
                    $(eval include $(_product_mk)) \
                , \
                    $(call mixin-debug, skipping nonexistent $(_product_mk) for group $(_group)) \
                ) \
                $(eval _product_mk :=) \
            , \
                $(call mixin-error, group $(_group) does not have option $(_opt))) \
        , \
            $(call mixin-warning, skipping unknown mixin group '$(_group)') \
        ) \
    ) \
    $(eval _group :=) \
    $(eval _opt :=) \
)
endef


define get-mixin-basedir
$(MIXIN_GROUP.$(strip $(1)).dir)
endef


# Ensure that for all mixins that one of them has been explicitly selected.
# If no selection was made and a 'default' option exists, inherit that.
define check-mixin-selections
$(foreach group,$(MIXIN_GROUPS), \
    $(if $(filter $(group),$(MIXIN_GROUPS_SELECTED)),, \
        $(eval _opts := $(MIXIN_GROUP.$(group).options)) \
        $(if $(filter default,$(_opts)), \
            $(call mixin-warning, using default option $(shell readlink $(MIXIN_GROUP.$(group).option.default)) for mixin group $(group)) \
            $(call inherit-mixin,$(group),default) \
        , \
            $(call mixin-error, selection for mixin group $(group) not specified! Available options: [$(_opts)]) \
        ) \
        $(eval _opts :=) \
    ) \
)
endef

# For all the selected mix-ins, include all the files with the specified
# name if it exists in the mixin directories
# $(1) Filename to scan for and include
define import-mixin-file
$(foreach group,$(MIXIN_GROUPS_SELECTED), \
    $(eval _path := $(MIXIN_GROUP.$(group).dir)/$(1)) \
    $(if $(wildcard $(_path)), \
        $(call mixin-debug, reading $(_path)) \
        $(eval include $(_path)) \
    , \
        $(call mixin-debug, skipping nonexistent $(_path) for mixin group $(group)) \
    ) \
    $(eval _path :=) \
)
endef


define composite-template
$(1): $(2)
	$(hide) mkdir -p $$(dir $$@)
	$(hide) awk 'FNR==1{print "# " FILENAME}1' $$^ > $$@
endef

# $(1) Filename of fragment to search for in the selected mixin directories
# $(2) Filename of generated output file to be placed in the ramdisk root
define assemble-composite-file
$(if,, \
    $(eval _frags := $(foreach group,$(MIXIN_GROUPS_SELECTED),$(wildcard $(call get-mixin-basedir, $(group))/$(1)))) \
    $(eval _filename := $(TARGET_ROOT_OUT)/$(2)) \
    $(if $(_frags), \
        $(eval $(call composite-template,$(_filename),$(_frags))) \
        $(eval ALL_DEFAULT_INSTALLED_MODULES += $(_filename)) \
    ) \
    $(eval _frags := ) \
    $(eval _filename := ) \
)
endef

