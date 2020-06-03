##############################################################################
#
# TARGET specific layer library
#
##############################################################################

UNIT_CFLAGS := $(filter-out -DTARGET_H=%,$(UNIT_CFLAGS))
UNIT_CFLAGS += -DTARGET_H=\"target_$(TARGET).h\"
UNIT_CFLAGS += -I$(OVERRIDE_DIR)/inc

ifneq ($(filter OS_GATEWAY_BCM52 OS_EXTENDER_BCM52,$(TARGET)),)

##
# Platform BCM dependencies
#
UNIT_DEPS += platform/bcm/src/lib/bcmwl
UNIT_DEPS += platform/bcm/src/lib/bcm_bsal

##
# Target layer sources
#
UNIT_SRC_TOP += $(OVERRIDE_DIR)/src/target_$(TARGET).c

endif

UNIT_EXPORT_CFLAGS := $(UNIT_CFLAGS)
