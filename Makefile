##
# Vendor specific Makefile
#

include $(VENDOR_DIR)/build/profile.mk

##
# Enable vendor specific OVSDB hooks
#
VENDOR_OVSDB_HOOKS := $(VENDOR_DIR)/ovsdb/common
VENDOR_OVSDB_HOOKS += $(VENDOR_DIR)/ovsdb/$(TARGET)

##
# Handle onboarding PSK and SSID for OS_EXTENDER_BCM52 target.
#
# BACKHAUL_PASS and BACKHAUL_SSID variables are required for generating the
# pre-populated WiFi related OVSDB entries needed for extender devices.
# (See also: ovsdb/OS_EXTENDER_BCM52/radio.json.sh)
#
ifeq ($(MAKECMDGOALS),)
ifeq ($(TARGET),OS_EXTENDER_BCM52)

ifeq ($(BACKHAUL_PASS),)
$(error TARGET=$(TARGET): Please provide BACKHAUL_PASS)
endif

ifeq ($(BACKHAUL_SSID),)
$(error TARGET=$(TARGET): Please provide BACKHAUL_SSID)
endif

export BACKHAUL_PASS=$(BACKHAUL_PASS)
export BACKHAUL_SSID=$(BACKHAUL_SSID)

endif
endif
