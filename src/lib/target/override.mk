##############################################################################
#
# TARGET specific layer library
#
##############################################################################

UNIT_CFLAGS := $(filter-out -DTARGET_H=%,$(UNIT_CFLAGS))
UNIT_CFLAGS += -DTARGET_H=\"target_BCM.h\"
UNIT_CFLAGS += -I$(OVERRIDE_DIR)/inc

##
# Target layer sources
#
UNIT_EXPORT_CFLAGS := $(UNIT_CFLAGS)

# UNIT_SRC_TOP += $(OVERRIDE_DIR)/src/target_$(TARGET).c

##
# Platform BCM dependencies
#
UNIT_DEPS += platform/bcm/src/lib/bcmwl
UNIT_DEPS += platform/bcm/src/lib/bcm_bsal


