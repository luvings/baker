#!/bin/bash

patch_boot_img() {
    patch_initrc() {
        # patch init.rc
        local INITRC=$STAGE/boot/init.rk30board.rc
        if grep -q "service cupsd" $INITRC; then
            echo ALREADY PATCHED
        else
            cat <<EOT >>$INITRC

service cupsd /system/cups/sbin/cupsd -f
    class main
    user root
    group inet
EOT
            echo PATCHED $INITRC
        fi
    }
    within_boot_img boot.img boot patch_initrc
}

patch_system_img() {
    # append 200M to system.img, and extract files in
    extract_cups() {
        # Files in android-print.tar.gz have system/ prefix
        sudo tar --strip-components=1 -xvf cups/android-print.tar.gz -C $STAGE/system
    }

    # expand system.img with 200M, and extract cups files to it
    within_ext4fs_img system.img system 200 extract_cups
}

execute() {
    [[ $# -eq 2 ]] || USAGE "$0 <original_firmware> <new_firmware>"
    firmware_unpack $1
    patch_boot_img
    patch_system_img
    firmware_pack $2
}

if [[ "$0" == "${BASH_SOURCE}" ]]; then
    . buildenv.sh
    execute "$@" 2>&1 | tee cups-patch-log-$(TIMESTAMP).log
else
    echo "source only for debug"
fi
