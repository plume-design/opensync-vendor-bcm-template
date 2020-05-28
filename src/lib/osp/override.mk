##############################################################################
#
# OSP layer library
#
##############################################################################

UNIT_CFLAGS := $(filter-out -DTARGET_H=%,$(UNIT_CFLAGS))

UNIT_SRC_TOP += $(if $(CONFIG_PM_ENABLE_LED),$(OVERRIDE_DIR)/src/osp_led.c,)
UNIT_SRC_TOP += $(if $(CONFIG_PM_ENABLE_TM),$(OVERRIDE_DIR)/src/osp_tm.c,)

UNIT_EXPORT_CFLAGS := $(UNIT_CFLAGS)
