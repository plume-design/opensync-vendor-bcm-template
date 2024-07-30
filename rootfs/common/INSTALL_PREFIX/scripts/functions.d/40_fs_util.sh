#!/bin/sh

# These funcitons provide the functionality of a writable overlay filesystem
# on top of a read-only filesystem which is usually a squashfs image.
# This can also be used for the in place upgrade functionality.

# {# jinja-parse #}
INSTALL_PREFIX={{INSTALL_PREFIX}}

get_active_partition_id()
{
    local id=
    local img=$(bcm_bootstate | grep -m 1 "Booted Partition:" | sed -r 's/^\s+Booted Partition:\s+(.*)$/\1/')

    if [ "$img" = "First" ]; then
        id=1
    elif [ "$img" = "Second" ]; then
        id=2
    fi

    echo "$id"
}

get_part_mtd()
{
    cat /proc/mtd | grep '"'$1'"' | cut -d':' -f1
}

get_ubi_dev()
{
    local MTD=${1}
    MTD=${MTD/mtd/}; # replace "mtd" with nothing

    local UBI=`grep -l -w $MTD /sys/class/ubi/*/mtd_num`
    UBI=${UBI/\/mtd_num/}; # remove "/mtd_num" from the path
    UBI=${UBI/\/sys\/class\/ubi\//}; # remove "/sys/class/ubi/" from the path
    local DEV=/dev/$UBI # mdev should already populate the new device node for ubi in /dev.

    echo "${DEV}"
}

ubifs_mkvol()
{
    # param1: MTD name (example: "common")
    # param2: UBIFS subvolume name (example: "common_config")
    # param3: UBIFS subvolume size (example: "1MiB")

    local MTD_NAME=${1}
    local VOL_NAME=${2}
    local VOL_SIZE=${3}

    local MTD=$(get_part_mtd $MTD_NAME)
    local UBIDEV=$(get_ubi_dev $MTD)

    logger "Creating UBIFS subvolume $VOL_NAME"
    ubimkvol $UBIDEV --name=$VOL_NAME --type=dynamic --size=$VOL_SIZE > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        logger "ERROR: Creating UBIFS subvolume $VOL_NAME failed"
        return 1
    fi

    return 0
}

ubifs_vol_exists()
{
    # param1: MTD name (example: "common")
    # param2: UBIFS subvolume name (example: "common_config")

    local MTD_NAME=${1}
    local VOL_NAME=${2}

    local MTD=$(get_part_mtd $MTD_NAME)
    local UBIDEV=$(get_ubi_dev $MTD)

    local UBINUM=${UBIDEV/\/dev\//}
    for name in $(cat /sys/class/ubi/${UBINUM}_*/name);
    do
        if [ "$name" == "$VOL_NAME" ]; then
            return 0
        fi
    done

    return 1
}

util_move_mounts()
{
    local DEST="$1"
    local MOUNTS=$(cut -d' ' -f2 /proc/mounts)
    local MNT
    # filter out '/' '$DEST' and '$DEST/*'
    MOUNTS=$(echo "$MOUNTS" | grep -v "^/$\|^${DEST}$\|^${DEST}/")
    # filter out sub-mounts because they are moved along with upper
    # mount points (eg. /dev/pts is moved together with /dev)
    for MNT in $MOUNTS; do
        MOUNTS=$(echo "$MOUNTS" | grep -v "^$MNT/.\+")
    done
    for MNT in $MOUNTS; do
        mkdir -p $DEST$MNT
        mount --move $MNT $DEST$MNT
    done
}

util_move_and_pivot_root()
{
    local DEST="$1"
    local PUT_OLD="$2"
    util_move_mounts "$DEST"
    mkdir -p "$PUT_OLD"
    pivot_root "$DEST" "$PUT_OLD"
}

create_overlay_partition()
{
    local MTD_NAME="$1"
    local OVERLAY_NAME="$2"
    local OVERLAY_SIZE="100MiB"

    if ! ubifs_vol_exists $MTD_NAME $OVERLAY_NAME ; then
        echo "ubifs_mkvol $MTD_NAME $OVERLAY_NAME $OVERLAY_SIZE"
        if ! ubifs_mkvol $MTD_NAME $OVERLAY_NAME $OVERLAY_SIZE ; then
            return 1
        fi
    fi
}

mount_overlay_partition()
{
    img_id=$(get_active_partition_id)
    if [ -z "$img_id" ]; then
        echo "unknown active partition" >&2
        return 1
    fi
    local MTD_NAME="image"
    local OVERLAY_NAME="rootfs_overlay${img_id}"

    if ! create_overlay_partition $MTD_NAME $OVERLAY_NAME ; then
        return 1
    fi

    if ! mount -t ubifs ubi:${OVERLAY_NAME} /overlay ; then
        echo "Error mounting overlay filesystem 'ubi:${OVERLAY_NAME}'"
        return 1
    fi
}

mount_overlay_filesystem()
{
    echo "Mounting overlay filesystem"

    mkdir -p /overlay/upper
    mkdir -p /overlay/work

    # use LAYERS if provided as arg or use default '/'
    local LAYERS="${1:-/}"

    if ! mount -t overlay overlay -o lowerdir=$LAYERS,upperdir=/overlay/upper,workdir=/overlay/work /overlay ; then
        echo "Error mounting overlayfs layer"
        return 1
    fi

    # Switch to new root filesystem
    util_move_and_pivot_root /overlay /overlay/rom

    # move overlay volume to /overlay to use same layout as openwrt
    mount --move /rom/overlay /overlay

    echo "Done mounting overlay filesystem"
}

mount_overlay()
{
    if grep ' / overlay ' /proc/mounts ; then
        # overlay can already be mounted by preinit
        echo "Overlay mounted"
        return 0
    fi

    if ! mount_overlay_partition ; then
        return 1
    fi

    mount_overlay_filesystem
}

