##
# Vendor specific Makefile
#

include $(VENDOR_DIR)/build/profile.mk

##
# Target specific OVSDB hooks can be enabled with:
#
# VENDOR_OVSDB_HOOKS := $(VENDOR_DIR)/ovsdb/common
# VENDOR_OVSDB_HOOKS += $(VENDOR_DIR)/ovsdb/$(TARGET)

##
# Handle onboarding PSK and SSID for OS_EXTENDER_BCM52 target.
#
# BACKHAUL_PASS and BACKHAUL_SSID variables are required for generating the
# pre-populated WiFi related OVSDB entries needed for extender devices.
# (See also: core/ovsdb/20_kconfig.radio.json.sh)
#
ifeq ($(TARGET),OS_EXTENDER_BCM52)

ifeq ($(BACKHAUL_PASS),)
$(error TARGET=$(TARGET): Please provide BACKHAUL_PASS)
endif

ifeq ($(BACKHAUL_SSID),)
$(error TARGET=$(TARGET): Please provide BACKHAUL_SSID)
endif

endif
