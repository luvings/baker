#!/bin/bash
set -euo pipefail

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

flash() {
    while [[ -n "${2:-}" ]]; do
        flash_sdpartition "$1" "$2"
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
