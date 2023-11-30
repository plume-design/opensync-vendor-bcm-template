##
# Vendor specific Makefile
#

##
# Target specific OVSDB hooks can be enabled with:
#
# VENDOR_OVSDB_HOOKS := $(VENDOR_DIR)/ovsdb/common
# VENDOR_OVSDB_HOOKS += $(VENDOR_DIR)/ovsdb/$(TARGET)

##
# Handle onboarding PSK and SSID for BCM targets.
# BACKHAUL_PASS and BACKHAUL_SSID variables are required for generating the
# pre-populated WiFi related OVSDB entries needed for extender devices.
# (See also: core/ovsdb/20_kconfig.radio.json.sh)
#
