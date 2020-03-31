#!/bin/sh
#
# Initializes and sets the fan to around 4500 RPMs.
#

echo "Setting fan to around 4500 RPMs (0x52)"
/usr/sbin/i2cset -y 0 0x52 0x01 0x52
