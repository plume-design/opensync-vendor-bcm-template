##############################################################################
#
# TARGET specific layer library
#
##############################################################################

ifneq ($(filter OS_GATEWAY_BCM52 OS_EXTENDER_BCM52,$(TARGET)),)

UNIT_CFLAGS := $(filter-out -DTARGET_H=%,$(UNIT_CFLAGS))
UNIT_CFLAGS += -DTARGET_H=\"target_$(TARGET).h\"
UNIT_CFLAGS += -I$(OVERRIDE_DIR)/inc

##
# Target layer sources
#
UNIT_SRC_TOP += $(OVERRIDE_DIR)/src/target_$(TARGET).c

else

UNIT_CFLAGS := $(filter-out -DTARGET_H=%,$(UNIT_CFLAGS))
UNIT_CFLAGS += -DTARGET_H=\"target_BCM.h\"
UNIT_CFLAGS += -I$(OVERRIDE_DIR)/inc

endif

UNIT_EXPORT_CFLAGS := $(UNIT_CFLAGS)

##
# Platform BCM dependencies
#
UNIT_DEPS += platform/bcm/src/lib/bcmwl
UNIT_DEPS += platform/bcm/src/lib/bcm_bsal


