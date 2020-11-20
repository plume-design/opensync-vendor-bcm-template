##############################################################################
#
# OSP layer library override
#
##############################################################################

UNIT_SRC_TOP += $(if $(CONFIG_PM_ENABLE_LED),$(OVERRIDE_DIR)/src/osp_led.c,)
UNIT_SRC_TOP += $(if $(CONFIG_PM_ENABLE_TM),$(OVERRIDE_DIR)/src/osp_tm.c,)
