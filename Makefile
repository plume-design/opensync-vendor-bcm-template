##
# Vendor specfic Makefile
#

include $(VENDOR_DIR)/build/profile.mk

##
# Enable vendor specific OVSDB hooks
#
VENDOR_OVSDB_HOOKS := $(VENDOR_DIR)/ovsdb/common
VENDOR_OVSDB_HOOKS += $(VENDOR_DIR)/ovsdb/$(TARGET)

##
# Handle onboarding psk and ssid for OS_EXTENDER_BCM52 target during build.
#
# Note that OS_ONBOARDING_PSK and OS_ONBOARDING_SSID variables are required
# for generating pre-populated wifi related OVSDB entries required by extender
# devices. (See: ovsdb/OS_EXTENDER_BCM52/radio.json.sh)
#
ifeq ($(MAKECMDGOALS),)
ifeq ($(TARGET),OS_EXTENDER_BCM52)

ifeq ($(OS_ONBOARDING_PSK),)
$(error TARGET=$(TARGET): Please provide OS_ONBOARDING_PSK)
endif

ifeq ($(OS_ONBOARDING_SSID),)
$(error TARGET=$(TARGET): Please provide OS_ONBOARDING_SSID)
endif

export OS_ONBOARDING_PSK=$(OS_ONBOARDING_PSK)
export OS_ONBOARDING_SSID=$(OS_ONBOARDING_SSID)

endif
endif
