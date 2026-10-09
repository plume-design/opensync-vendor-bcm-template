#!/bin/sh

# These functions provide the functionality of a writable overlay filesystem
# on top of a read-only filesystem, which is usually a squashfs image.
# This can also be used for the in place upgrade functionality.

# Determine the flash type based on the root device
# Outputs "eMMC" or "NAND" on success, nothing on failure.
get_flash_type()
(
    root_dev=$(sed -e 's/^.*root=//' -e 's/ .*$//' /proc/cmdline) || return 1
    case "$root_dev" in
        "/dev/mmcblk"*)   echo "eMMC" ;;
        "/dev/ubiblock"*) echo "NAND" ;;
        "ubi:"*)          echo "NAND" ;;
        *)
            echo "Unable to determine flash type from root device '$root_dev'" >&2
            return 1
            ;;
    esac
)

# Determine the MTD partition layout version
# Outputs "1" (legacy) or "2" (new) on success, nothing on failure.
get_mtd_layout_version()
(
    # From SDK 5.4.2, there are only two mtd partitions: loader and image,
    # ubi0 is attached to image (mtd2) and mount all ubi volumes under ubi0.
    image_mtd=$(get_part_mtd image) || return 1
    if [ "${image_mtd}" = "mtd2" ]; then
        echo 2
    else
        echo 1
    fi
)

# Determine the active boot partition ID
# Outputs "1" or "2" on success, nothing on failure.
get_active_partition_id()
(
    img=$(bcm_bootstate | grep "Booted Partition:" | sed -r 's/^\s+Booted Partition:\s+(.*)$/\1/') || return 1

    if [ "$img" = "First" ]; then
        echo 1
    elif [ "$img" = "Second" ]; then
        echo 2
    else
        echo "Unable to determine active partition ID" >&2
        return 1
    fi
)

# Retrieve the partition number for a given MTD partition name
get_part_mtd()
(
    grep '"'$1'"' /proc/mtd | cut -d':' -f1
)

# Move all mount points to a new destination
util_move_mounts()
(
    dest="$1"
    # Get all mount points except the root mount point, the destination, all already under
    # destination, and the /proc mount point which shall be moved last as "mount" requires it.
    mounts=$(cut -d' ' -f2 /proc/mounts | sort | grep -v "^/$\|^$dest$\|^$dest/.*$\|^/proc$")
    mounts="$mounts /proc"
    # Filter out sub-mounts because they are moved together with parent
    # mount points (e.g., /dev/pts is moved together with /dev).
    for mnt in $mounts; do
        mounts=$(echo "$mounts" | grep -v "^$mnt/.\+")
    done
    # Move mount points to the new destination
    for mnt in $mounts; do
        if mountpoint -q "$mnt"; then
            mkdir -p "$dest$mnt"
            mount --move "$mnt" "$dest$mnt"
        fi
    done
)

mount_overlay_partition()
(
    flash_type="$(get_flash_type)" || return 1
    if [ "$flash_type" = "NAND" ]; then
        part_ver=$(get_mtd_layout_version) || return 1
        if [ "${part_ver}" = "1" ]; then
            overlay_name=rootfs_overlay
        elif [ "${part_ver}" = "2" ]; then
            # From SDK5.4.2, search the id for current rootfs overlay
            part_id=$(get_active_partition_id) || return 1
            overlay_name=rootfs${part_id}_overlay
        else
            echo "Unknown partition version '$part_ver'" >&2
            return 1
        fi

        mount -t ubifs "ubi:${overlay_name}" /overlay || {
            echo "Unable to mount overlay filesystem 'ubi:${overlay_name}'"
            return 1
        }
    else
        echo "Unsupported flash type '$flash_type'"
        return 1
    fi
)

mount_overlay_filesystem()
(
    echo "Mounting overlay filesystem"

    mkdir -p /overlay/upper
    mkdir -p /overlay/work

    mount -t overlay overlay -o lowerdir=/,upperdir=/overlay/upper,workdir=/overlay/work /overlay || return 1

    # Move mount points to the overlay
    util_move_mounts /overlay

    # Switch to new root filesystem
    echo "Pivoting overlay root"
    mkdir -p /overlay/rom
    pivot_root /overlay /overlay/rom

    # Move overlay volume to /overlay to use the same layout as openwrt
    mount --move /rom/overlay /overlay

    echo "Done mounting overlay filesystem"
)

mount_overlay()
(
    if grep ' / overlay ' /proc/mounts ; then
        # overlay can already be mounted by preinit
        echo "Overlay mounted"
        return 0
    fi

    if ! mount_overlay_partition ; then
        return 1
    fi

    mount_overlay_filesystem
)
