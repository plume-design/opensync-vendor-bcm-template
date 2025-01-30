##
# TARGET definitions
#
# NOTE: A single vendor repository may contain multiple targets,
# which share some portions of code.
#
BCM_TEMPLATE_TARGETS := OS_BCM947622DVT_EXT OS_BCM947622DVT_BCM54 OS_BCM947622DVTCH6
BCM_TEMPLATE_TARGETS += OS_BCM96755TBRHX OS_BCM96755TBRHX_BCM54
BCM_TEMPLATE_TARGETS += OS_BCM94916REF2_BCM54 OS_BCM96766REF1_BCM54

OS_TARGETS          += $(BCM_TEMPLATE_TARGETS)

##
# BCM template targets
#

ifneq ($(filter $(TARGET),$(BCM_TEMPLATE_TARGETS)),)

PLATFORM            := bcm

# By default, search through all service-provider directories
# starting with "local"
SERVICE_PROVIDERS ?= local ALL

# Default image deployment profile which must be defined in one of the cloned
# service-provider directories. The "local" profile is found in the "local"
# service provider repository.
export IMAGE_DEPLOYMENT_PROFILE ?= local

VENDOR              := bcm-template
VENDOR_DIR          := vendor/$(VENDOR)

ARCH_MK             := platform/bcm/build/bcm52.mk
KCONFIG_TARGET      ?= $(VENDOR_DIR)/kconfig/targets/$(TARGET)
-include $(VENDOR_DIR)/build/$(TARGET).mk


endif # BCM_TEMPLATE_TARGETS
