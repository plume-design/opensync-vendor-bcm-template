#!/bin/sh
# {# jinja-parse #}
INSTALL_PREFIX={{INSTALL_PREFIX}}

# Remove br0 that is created by L07 SDK
ip link del br0

# Create run dir for dnsmasq
mkdir -p /var/run/dnsmasq

# Start openvswitch
echo -n 'Starting Open vSwitch ...'
/etc/init.d/openvswitch start

# Add default internal bridge
sleep 1

# Add offset to a MAC address
mac_set_local_bit()
{
    local MAC="$1"

    # ${MAC%%:*} - first digit in MAC address
    # ${MAC#*:} - MAC without first digit
    printf "%02X:%s" $(( 0x${MAC%%:*} | 0x2 )) "${MAC#*:}"
}

# Get the MAC address of an interface
mac_get()
{
    ifconfig "$1" | grep -o -E '([A-F0-9]{2}:){5}[A-F0-9]{2}'
}

##
# Configure bridges
#
MAC_ETH0=$(mac_get eth0)
MAC_BRHOME=$(mac_set_local_bit ${MAC_ETH0})

echo "Adding br-wan with MAC address $MAC_ETH0"
ovs-vsctl add-br br-wan
ovs-vsctl set bridge br-wan other-config:hwaddr="$MAC_ETH0"
ovs-vsctl set int br-wan mtu_request=1500

# This is gateway example with one ethernet port,
# so we add eth0 into br-wan where dhcpc is running
ovs-vsctl add-port br-wan eth0

echo "Adding br-home with MAC address $MAC_BRHOME"
ovs-vsctl add-br br-home
ovs-vsctl set bridge br-home other-config:hwaddr="$MAC_BRHOME"
ovs-ofctl add-flow br-home table=0,priority=50,dl_type=0x886c,actions=local

echo "Adding br-home.l2uf1"
ovs-vsctl add-port br-home br-home.l2uf1 -- set interface br-home.l2uf1 type=internal ofport_request=500
ovs-ofctl add-flow br-home "table=0,priority=250,dl_dst=01:00:00:00:00:00/01:00:00:00:00:00,dl_type=0x05ff,actions=NORMAL,output:500"
ifconfig br-home.l2uf1 up

# Enable radios
ip link set wl0 up
ip link set wl1 up

# Configure ARPs
echo 1 | tee /proc/sys/net/ipv4/conf/*/arp_ignore

##
# Install and configure SSL certs
#
mkdir -p /var/certs
cp ${INSTALL_PREFIX}/certs/awsca.pem       /var/certs/
cp ${INSTALL_PREFIX}/certs/ca.pem          /var/certs/
cp ${INSTALL_PREFIX}/certs/client.pem      /var/certs/
cp ${INSTALL_PREFIX}/certs/client_dec.key  /var/certs/

# Update Open_vSwitch table: Must be done here instead of pre-populated
# because row doesn't exist until openvswitch is started
ovsdb-client transact '
["Open_vSwitch", {
    "op": "insert",
    "table": "SSL",
    "row": {
        "ca_cert": "/var/certs/ca.pem",
        "certificate": "/var/certs/client.pem",
        "private_key": "/var/certs/client_dec.key"
    },
    "uuid-name": "ssl_id"
}, {
    "op": "update",
    "table": "Open_vSwitch",
    "where": [],
    "row": {
        "ssl": ["set", [["named-uuid", "ssl_id"]]]
    }
}]'

# Change interface stats update interval to 1 hour
ovsdb-client transact '
["Open_vSwitch", {
    "op": "update",
    "table": "Open_vSwitch",
    "where": [],
    "row": {
        "other_config": ["map", [["stats-update-interval", "3600000"] ]]
    }
}]'
