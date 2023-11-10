#!/bin/bash
set -euo pipefail

# find root dir
ROOT_DIR="$(cd $(dirname $0) && pwd)"
while [[ $ROOT_DIR != "/" ]]; do
    [ -d $ROOT_DIR/kernel ] && break
    ROOT_DIR=$(dirname $ROOT_DIR)
done
if [[ $ROOT_DIR = "/" ]]; then echo "Cannot determint root directory!" >&2; exit 1; fi

cd $ROOT_DIR/baker

. buildenv.sh -q
. $PROFILE/rk3328
clean

mkdir -p $STAGE

# copy u-boot
cp $ROOT_DIR/u-boot/idbloader.img $STAGE/
cp $ROOT_DIR/u-boot/uboot.img $STAGE/
cp $ROOT_DIR/u-boot/trust.img $STAGE/

# copy kernel
cp $ROOT_DIR/kernel/kernel.img $STAGE/
cp $ROOT_DIR/kernel/resource.img $STAGE/

# copy rootfs
cp -L $ROOT_DIR/buildroot/output/images/rootfs.ext2 $STAGE/rootfs.img

# copy misc files
cp $ROOT_DIR/recovery/etc/rk3328/parameter.txt $STAGE/parameter
sdfirmware_pack $ROOT_DIR/rk3328-sdmultiboot-$(TIMESTAMP).img
