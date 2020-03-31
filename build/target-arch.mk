##
# TARGET definitions
#
# NOTE: A single vendor repository may contain multiple targets,
# which share some portions of code. This template contains two
# target implementations: OS_GATEWAY_BCM52 and OS_EXTENDER_BCM52.
#
BCM_TEMPLATE_TARGETS := OS_GATEWAY_BCM52 OS_EXTENDER_BCM52

OS_TARGETS          += $(BCM_TEMPLATE_TARGETS)

##
# BCM template targets
#
ifneq ($(filter $(TARGET),$(BCM_TEMPLATE_TARGETS)),)

PLATFORM            := bcm

VENDOR              := bcm-template
VENDOR_DIR          := vendor/$(VENDOR)

ARCH_MK             := $(VENDOR_DIR)/build/$(TARGET).mk
KCONFIG_TARGET      ?= $(VENDOR_DIR)/kconfig/targets/$(TARGET)

endif # BCM_TEMPLATE_TARGETS
