# Saves a set of known compilation flags, creating the directory
# and the destination file if not already present.
#
# $(1): the complete file name including path
#
define save-flags-to-file
	$(hide) [ -d `dirname $(1)` ] || mkdir -p `dirname $(1)`
	$(hide) echo -n > $(1)
	$(hide) echo HOST_GLOBAL_CFLAGS=\'$$(HOST_GLOBAL_CFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_AAPT_FLAGS=\'$$(PRIVATE_AAPT_FLAGS)\' >> $(1)
	$(hide) echo PRIVATE_ARFLAGS=\'$$(PRIVATE_ARFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_ARM_CFLAGS=\'$$(PRIVATE_ARM_CFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_ASFLAGS=\'$$(PRIVATE_ASFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_CFLAGS=\'$$(PRIVATE_CFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_C_INCLUDES=\'$$(PRIVATE_C_INCLUDES)\' >> $(1)
	$(hide) echo PRIVATE_CONLYFLAGS=\'$$(PRIVATE_CONLYFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_CPPFLAGS=\'$$(PRIVATE_CPPFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_DEBUG_CFLAGS=\'$$(PRIVATE_DEBUG_CFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_DX_FLAGS=\'$$(PRIVATE_DX_FLAGS)\' >> $(1)
	$(hide) echo PRIVATE_JAVACFLAGS=\'$$(PRIVATE_JAVACFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_LDFLAGS=\'$$(PRIVATE_LDFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_RTTI_FLAG=\'$$(PRIVATE_RTTI_FLAG)\' >> $(1)
	$(hide) echo PRIVATE_TARGET_GLOBAL_CFLAGS=\'$$(PRIVATE_TARGET_GLOBAL_CFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_TARGET_GLOBAL_CPPFLAGS=\'$$(PRIVATE_TARGET_GLOBAL_CPPFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_YACCFLAGS=\'$$(PRIVATE_YACCFLAGS)\' >> $(1)
	$(hide) echo PRIVATE_NO_CRT=\'$$(PRIVATE_NO_CRT)\' >> $(1)
	$(hide) echo PRIVATE_NO_DEFAULT_COMPILER_FLAGS=\'$$(PRIVATE_NO_DEFAULT_COMPILER_FLAGS)\' >> $(1)
endef

# Creates a couple of make targets and recipes to save the new
# compilation flags and compare them to the previous existing flags
# (if any).
#
# The actual content of the files are compared (with "diff") and if
# different, the previous flag file is updated with the content of
# the new one.
#
# Note, we don't use "acp" in the recipe because "acp" is a host
# target and we need the logic to check host C/C++ flags as well,
# using "acp" would create a circular dependency.
#
# $(1): The file containing the current (previous) compilation flags
# $(2): The file containing the new (to verify) compilation flags
#
define add-target-for-compilation-flags

.PHONY : $(2)
$(2) :
	$(hide) rm -f $$@
	$(call save-flags-to-file,$$@)

$(1) : $(2)
	$(hide) if [ ! -r $$@ ]; then \
			cp -f $$< $$@; \
		elif ! diff -q $$< $$@ &>/dev/null; then \
			echo "Warning: compilation flags have changed in \"$(LOCAL_MODULE)\":"; \
			type wdiff &>/dev/null && wdiff -3 $$< $$@; \
			echo "Rebuilding \"$(LOCAL_MODULE)\" ..."; \
			cp -f $$< $$@; \
		fi
	$(hide) rm -f $$<

endef

# Convenient function to create the targets for make
#
# $(1): The file name (including path) to store the compilation flags
#
define save-current-compilation-flags
$(eval $(call add-target-for-compilation-flags,$(1),$(patsubst %.flags,%.tempflags,$(1))))
endef

# Plug the mechanism into the build system:
# - The module depends on the generation of the file containing the
#   compilation flags, so that the PHONY target is generated only
#   once per module.
# - Whereas all the built objects depend on the compilation flags file
#   so that whenever the compilation flags change, the objects get
#   recompiled.
#
$(LOCAL_BUILT_MODULE): $(call save-current-compilation-flags,$(intermediates)/compilation.flags)
$(all_objects): $(intermediates)/compilation.flags

