##
# SDK dependent build time defines
#
DRIVER_VERSION := impl$(shell grep BCM_WLIMPL= $(PROFILE_DIR)/$(shell basename $(PROFILE_DIR)) | cut -d= -f2)

SDK_INCLUDES += -I$(BCM_FSBUILD_DIR)/public/include
SDK_INCLUDES += -I$(BCM_FSBUILD_DIR)/gpl/include
SDK_INCLUDES += -I$(BCM_FSBUILD_DIR)/public/include/protobuf-c
SDK_INCLUDES += -I$(BRCMDRIVERS_DIR)/broadcom/net/wl/$(DRIVER_VERSION)/main/src/include/
SDK_INCLUDES += -I$(BRCMDRIVERS_DIR)/broadcom/net/wl/$(DRIVER_VERSION)/main/src/common/include
SDK_INCLUDES += -I$(BRCMDRIVERS_DIR)/broadcom/net/wl/$(DRIVER_VERSION)/main/src/shared/bcmwifi/include
INCLUDES     += $(SDK_INCLUDES)
DEFINES      += -Wno-strict-aliasing
DEFINES      += -Wno-unused-but-set-variable
DEFINES      += -Wno-deprecated-declarations
DEFINES      += -Wno-clobbered
LDFLAGS      += -L$(BCM_FSBUILD_DIR)/lib
LDFLAGS      += -L$(BCM_FSBUILD_DIR)/public/lib
LDFLAGS      += -L$(BCM_FSBUILD_DIR)/gpl/lib
SDK_ROOTFS   := $(INSTALL_DIR)
