##############################################################################
#
# OSP layer library override
#
##############################################################################

UNIT_SRC_TOP += $(if $(CONFIG_OSP_UNIT_BCM_TEMPLATE), $(OVERRIDE_DIR)/src/osp_unit_bcm_template.c)

UNIT_SRC_TOP += $(if $(CONFIG_PM_ENABLE_TM),$(OVERRIDE_DIR)/src/osp_tm_bcm_template.c,)
UNIT_SRC_TOP += $(if $(CONFIG_PM_ENABLE_TM),$(OVERRIDE_DIR)/src/osp_tm_therm_tbls.c,)

UNIT_SRC := $(filter-out src/osp_temp_srcs.c,$(UNIT_SRC))
UNIT_SRC_TOP += $(OVERRIDE_DIR)/src/osp_temp_srcs.c
