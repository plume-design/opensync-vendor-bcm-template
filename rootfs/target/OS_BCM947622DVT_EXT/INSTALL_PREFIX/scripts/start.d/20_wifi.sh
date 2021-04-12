#!/bin/sh

# Use Q1/153 country code for reference board. This is a US country
# code that supports HT160 and works on both 2.4 and 5g radios
# It is reported as: US (Q1/153) UNITED STATES

wl -i wl0 down
wl -i wl1 down
wl -i wl2 down

wl -i wl0 country Q1/153
wl -i wl1 country Q1/153
wl -i wl2 country Q1/153

