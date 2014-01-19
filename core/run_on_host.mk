###########################################
## Special target to run executable on host through
## make [LOCAL_MODULE]-run-on-host
###########################################


# RUN_ON_HOST_DEPS - dependencies to build before running executable
# RUN_ON_HOST_EXEC - executable to run
# RUN_ON_HOST_FLAGS - flags passed to executable
# RUN_ON_HOST_DIRS - directories to make before running executable
# RUN_ON_HOST_PREPARE - commands to run before running executable
# RUN_ON_HOST_FINISH - commands to run after running executable

ifeq ($(HOST_OS)-$(HOST_ARCH),linux-x86)
ifeq ($(TARGET_ARCH),$(filter $(TARGET_ARCH),x86 x86_64))

ifeq ($(TARGET_ARCH),x86)
 LINKER := linker
else
 LINKER := linker64
endif

$(LOCAL_MODULE)-run-on-host: PRIVATE_RUN_ON_HOST_EXEC := $(LOCAL_MODULE_PATH)/$(LOCAL_MODULE)
$(LOCAL_MODULE)-run-on-host: PRIVATE_RUN_ON_HOST_FLAGS := $(RUN_ON_HOST_FLAGS)
$(LOCAL_MODULE)-run-on-host: PRIVATE_RUN_ON_HOST_DIRS := /system/bin $(RUN_ON_HOST_DIRS)
$(LOCAL_MODULE)-run-on-host: PRIVATE_RUN_ON_HOST_PREPARE := $(RUN_ON_HOST_PREPARE)
$(LOCAL_MODULE)-run-on-host: PRIVATE_RUN_ON_HOST_FINISH := $(RUN_ON_HOST_FINISH)

$(LOCAL_MODULE)-run-on-host: $(LOCAL_MODULE)-run-on-host-prepare
	-ANDROID_DATA=$(TARGET_OUT_DATA) \
	ANDROID_ROOT=$(TARGET_OUT) \
	LD_LIBRARY_PATH=$(TARGET_OUT_SHARED_LIBRARIES) \
		$(PRIVATE_RUN_ON_HOST_EXEC) $(PRIVATE_RUN_ON_HOST_FLAGS)
	$(PRIVATE_RUN_ON_HOST_FINISH)

$(LOCAL_MODULE)-run-on-host-prepare: $(LOCAL_MODULE) $(TARGET_OUT_EXECUTABLES)/$(LINKER) $(TARGET_OUT_EXECUTABLES)/sh $(RUN_ON_HOST_DEPS)
	for dir in $(PRIVATE_RUN_ON_HOST_DIRS); do \
	 if [ ! -d $$dir ]; then \
	  echo "Attempting to create $$dir"; \
	  sudo mkdir -p -m 0777 $$dir; \
	 fi \
        done
	mkdir -p $(TARGET_OUT_DATA)/local/tmp
	cp $(TARGET_OUT_EXECUTABLES)/$(LINKER) /system/bin
	cp $(TARGET_OUT_EXECUTABLES)/sh /system/bin
	$(PRIVATE_RUN_ON_HOST_PREPARE)
	sleep 1

endif
endif
