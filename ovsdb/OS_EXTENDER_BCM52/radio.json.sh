##
# Pre-populate WiFi related OVSDB tables
#

generate_onboarding_ssid()
{
    cat << EOF
        "$BACKHAUL_SSID"
EOF
}

generate_onboarding_psk()
{
    cat << EOF
        ["map",
            [
                ["encryption","WPA-PSK"],
                ["key", "$BACKHAUL_PASS"]
            ]
       ]
EOF
}

cat << EOF
[
    "Open_vSwitch",
    {
        "op": "insert",
        "table": "Wifi_VIF_Config",
        "row": {
            "enabled": true,
            "vif_dbg_lvl": 0,
            "if_name": "wl0",
            "bridge": "",
            "mode": "sta",
            "wds": false,
            "vif_radio_idx": 0,
            "ssid": $(generate_onboarding_ssid),
            "security": $(generate_onboarding_psk)
        },
        "uuid-name": "id0"
    },
    {
        "op": "insert",
        "table": "Wifi_VIF_Config",
        "row": {
            "enabled": true,
            "vif_dbg_lvl": 0,
            "if_name": "wl1",
            "bridge": "",
            "mode": "sta",
            "wds": false,
            "vif_radio_idx": 0,
            "ssid": $(generate_onboarding_ssid),
            "security": $(generate_onboarding_psk)
        },
        "uuid-name": "id1"
    },
    {
        "op": "insert",
        "table": "Wifi_Radio_Config",
        "row": {
            "enabled": true,
            "if_name": "wl0",
            "freq_band": "5G",
            "channel_mode": "cloud",
            "channel_sync": 0,
            "hw_type": "bcm4366",
            "hw_config": ["map",[]],
            "ht_mode": "HT80",
            "hw_mode": "11ac",
            "vif_configs": ["set", [ ["named-uuid", "id0"] ] ]
        }
    },
    {
        "op": "insert",
        "table": "Wifi_Radio_Config",
        "row": {
            "enabled": true,
            "if_name": "wl1",
            "freq_band": "2.4G",
            "channel_mode": "cloud",
            "channel_sync": 0,
            "hw_type": "bcm47189",
            "hw_config": ["map",[]],
            "ht_mode": "HT40",
            "hw_mode": "11n",
            "vif_configs": ["set", [ ["named-uuid", "id1"] ] ]
        }
    }
]
EOF
