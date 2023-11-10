#!/bin/bash
set -euo pipefail

FATAL() {
    echo "Fatal: $*"
    exit 1
} >&2

[[ -n "${1:-}" ]] || FATAL "No action specified"

# find root dir
ROOT_DIR="$(cd $(dirname $0) && pwd)"
while [[ $ROOT_DIR != "/" ]]; do
    [ -d $ROOT_DIR/kernel ] && break
    ROOT_DIR=$(dirname $ROOT_DIR)
done
[[ $ROOT_DIR != "/" ]] || FATAL "Cannot determint root directory!"

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
MAKE_OPTS="--jobs=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`"

uboot() {
    cd u-boot
    make $MAKE_OPTS rk3328_box_defconfig all

    # Pack idbloader.img
    # first import value from .ini file
    SAVED_PATH="$PATH"
    MINIALL_INI=./tools/rk_tools/RKBOOT/RK3328MINIALL.ini
    eval "$(grep -v '^\[' $MINIALL_INI)"
    PATH="$SAVED_PATH"
    dd if=${!LOADER1} of=DDRTEMP bs=4 skip=1
    $ROOT_DIR/baker/bin/mkimage -n rk3328 -T rksd -d DDRTEMP idbloader.img
    rm -f DDRTEMP
    cat ${!LOADER2} >> idbloader.img
    echo "pack idbloader.img success!"
}

kernel() {
    cd kernel
    make $MAKE_OPTS rockchip_linux_defconfig rk3328-firefly-mini.img
}

buildroot() {
    cd buildroot
    make $MAKE_OPTS rockchip_rk3399_defconfig all
}

all() {
    uboot
    kernel
    buildroot
}

cd "${ROOT_DIR}"
"$@"
