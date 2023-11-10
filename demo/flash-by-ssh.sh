#!/bin/bash
set -euo pipefail

DEVIP=168.168.100.169

if [[ $# -eq 0 ]]; then
    echo>&2 "Usage: $0 { kernel | flash <part> <image> [<part> <image>...] }"
    exit 1
fi

# find root dir
ROOT_DIR="$(cd $(dirname $0) && pwd)"
while [[ $ROOT_DIR != "/" ]]; do
    [ -d $ROOT_DIR/kernel ] && break
    ROOT_DIR=$(dirname $ROOT_DIR)
done
if [[ $ROOT_DIR = "/" ]]; then echo "Cannot determint root directory!" >&2; exit 1; fi

cd $ROOT_DIR
. ./baker/buildenv.sh -q

PARAMETER=$(FIND_FIRST_AVAILABE_FILE "parameter" $ROOT_DIR $STAGE) || FATAL "parameter not found"
I "Using $PARAMETER"
import_partitions_from_parameter $PARAMETER

flash() {
    while [[ -n "${2:-}" ]]; do
        local part="${1}"
        local PART="${part^^}"
        local IMAGE="$2"
        local PARTNUM="PART_${PART}_PARTNUM"
        PARTNUM=${!PARTNUM}
        [[ -n "$PARTNUM" ]] || FATAL "Partnum of $PART not found"
        CHECK_FILE_EXISTS "$IMAGE"
        I "Flashing /dev/mmcblk0p${PARTNUM} ($part) with $IMAGE..."
        cat $IMAGE | ssh root@$DEVIP dd of=/dev/mmcblk0p${PARTNUM} bs=1M conv=notrunc
        shift 2
    done
}

kernel() {
    flash kernel kernel/kernel.img resource kernel/resource.img
}

uboot() {
    flash uboot u-boot/uboot.img
}

uboot_all() {
    flash uboot u-boot/uboot.img trust u-boot/trust.img
    local part=idb
    local IMAGE="u-boot/idbloader.img"
    CHECK_FILE_EXISTS "$IMAGE"
    I "Flashing /dev/mmcblk0 ($part) with $IMAGE..."
    cat $IMAGE | ssh root@$DEVIP dd of=/dev/mmcblk0 seek=$((0x40)) conv=notrunc
}

CMD=$1
shift
$CMD "$@"
