##############################################################################
#
# OSP layer library override
#
##############################################################################

UNIT_SRC_TOP += $(if $(CONFIG_OSP_UNIT_BCM_TEMPLATE), $(OVERRIDE_DIR)/src/osp_unit_bcm_template.c)

UNIT_SRC_TOP += $(if $(CONFIG_PM_ENABLE_LED),$(OVERRIDE_DIR)/src/osp_led.c,)
UNIT_SRC_TOP += $(if $(CONFIG_PM_ENABLE_TM),$(OVERRIDE_DIR)/src/osp_tm.c,)
