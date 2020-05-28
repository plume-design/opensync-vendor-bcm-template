#!/bin/sh
#
# Collect system logs, state and current configuration.
#

LOGPULL_TYPE="local"
LOGPULL_DIR=/tmp/logpull/logpull_$(date +"%Y%m%d_%H%M%S")
LOGPULL_ARCHIVE=/tmp/logpull/logpull_$(date +"%Y%m%d_%H%M%S").tar.gz

##
# Logging helpers
#
log()
{
    logger -s -p NOTICE -t LOGPULL "$@" >&2
}

##
# Collect helpers
#
collect_cmd()
{
    OUTPUT="$LOGPULL_DIR/$(echo -n "$@" | tr -C "A-Za-z0-9.-" _)"
    ("$@") > "$OUTPUT" 2>&1 || true
}

collect_file()
{
    local filename="$(echo "$1" | sed "s,/,_,g")"
    [ -e "$1" ] && cp "$1" $LOGPULL_DIR/$filename
}

collect_log_safe()
{
    # Keeps the log filename and doesn't copy the file which is safer in
    # terms of memory usage on tmpfs.
    [ -e "$1" ] && {
        ln -s "$1" $LOGPULL_DIR
    }
}

##
# Collects data and packs into archive
#
collect_and_pack()
{
    log "Collecting logpull data ..."

    mkdir -p $LOGPULL_DIR

    # Collect common Linux info
    collect_cmd uname -a
    collect_cmd uptime
    collect_cmd date
    collect_cmd ps w
    collect_cmd free
    collect_cmd df -h
    collect_cmd dmesg
    collect_cmd ifconfig -a
    collect_cmd ip a
    collect_cmd ip -d link show
    collect_cmd ip neigh show
    collect_cmd route -n
    collect_cmd iptables -L -v -n
    collect_cmd iptables -t nat -L -v -n
    collect_cmd ethtool eth0
    collect_cmd lsmod
    collect_cmd ls -l /etc/rc3.d/
    collect_cmd mpstat -A -I ALL
    collect_cmd pidstat -Ir -T ALL
    collect_file /proc/net/dev
    collect_file /proc/stat
    collect_file /proc/meminfo
    collect_file /proc/loadavg
    collect_file /var/etc/dnsmasq.conf
    collect_file /tmp/dhcp.leases
    collect_file /etc/resolv.conf
    collect_file /tmp/resolv.conf

    # Collect board related info
    collect_file /proc/nvram/boardid

    # Collect OVS related info
    collect_cmd ovsdb-client dump
    collect_cmd ovsdb-client -f json dump
    collect_cmd ovsdb-tool show-log /tmp/etc/openvswitch/conf.db
    collect_cmd ovs-vsctl show
    collect_cmd ovs-ofctl dump-flows br-wan
    collect_cmd ovs-ofctl dump-flows br-home
    collect_cmd ovs-vsctl list bridge
    collect_cmd ovs-vsctl list interface
    collect_cmd ovs-appctl ovs/route/show
    collect_cmd ovs-appctl dpif/show
    collect_cmd ovs-appctl dpif/dump-flows br-home
    collect_cmd ovs-appctl fdb/show br-home
    collect_cmd ovs-appctl fdb/show br-wan
    collect_cmd ovs-appctl mdb/show br-home
    collect_cmd ovs-appctl mdb/show br-wan

    collect_file /var/tmp/openvswitch/conf.db

    # Collect wifi related info
    collect_cmd nvram getall

    for iface in $(ls /sys/class/net/ | grep wl); do
        collect_cmd wlctl -i $iface status
        collect_cmd wlctl -i $iface assoclist
        collect_cmd wlctl -i $iface macmode
        collect_cmd wlctl -i $iface mac
        collect_cmd wlctl -i $iface ver
    done

    # Collect system log files
    collect_log_safe /var/log/messages

    # Collect OpenSync related info
    collect_file /.version

    # Pack collected information into archive
    tar cvhzf $LOGPULL_ARCHIVE -C $(dirname $LOGPULL_DIR) $(basename $LOGPULL_DIR) >&2
    rm $LOGPULL_DIR/*
    rmdir $LOGPULL_DIR

    # Info
    log "Archive size: $(wc -c $LOGPULL_ARCHIVE | awk '{ print $1 }') B"

    case $LOGPULL_TYPE in
        local)
            log "Archive name: $LOGPULL_ARCHIVE"
            break
            ;;
        stdout)
            cat $LOGPULL_ARCHIVE && rm $LOGPULL_ARCHIVE
            break
            ;;
        remote)
            # TODO
            break
            ;;
    esac

    exit 0
}

##
# Main
#

case "$1" in
    --stdout)
        LOGPULL_TYPE="stdout"
        break
        ;;
    --remote)
        LOGPULL_TYPE="remote"
        break
        ;;
    --local|*)
        LOGPULL_TYPE="local"
        break
        ;;
esac

collect_and_pack
