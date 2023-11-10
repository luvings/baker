firmware_unpack () {
    (
        [[ "$1" ]] || USAGE "firmware_unpack <Firmware>"
        set -e
        local FIRMWARE="$1"
        CLEAN_MKDIR $UNPACK
        $BIN/rkImageMaker -unpack $FIRMWARE $UNPACK
        $BIN/afptool -unpack $UNPACK/firmware.img $UNPACK
        rm -f $UNPACK/{firmware.img,boot.bin}
        if [[ -d $UNPACK/Image ]]; then
            mv $UNPACK/Image/* $UNPACK/
            rmdir $UNPACK/Image
        fi
        od -A n -j $((0x15)) -N 4 -t x4 $FIRMWARE | tr -d '\n ' > $UNPACK/chip

        echo
        BANNER "Unpacked $FIRMWARE at \$UNPACK ($UNPACK)"
        ls -lh $UNPACK
    )
}

firmware_pack () {
    (
        [[ "$1" ]] || USAGE "firmware_pack <Firmware>"
        set -e
        local FIRMWARE="$1"
        local BOOTLOADER=

        # check CHIP_TYPE
        local CHIP_TYPE=${OPT_IMG_MAKER_CHIP_TYPE:-}
        if [[ ! "$CHIP_TYPE" ]]; then
            case "$(cat $UNPACK/chip 2>/dev/null)" in
                "00000050") CHIP_TYPE=rk29;;
                "00000060") CHIP_TYPE=rk30;;
                "00000070") CHIP_TYPE=rk31;;
                "00000080") CHIP_TYPE=rk32;;
                "33333043") CHIP_TYPE=RK330C;;
                *) F "Unknown chip and OPT_IMG_MAKER_CHIP_TYPE not specified!";;
            esac
        fi

        CLEAN_MKDIR $PACK
        COPY_FIRST_AVAILABE_FILE \
            package-file $PACK $STAGE $UNPACK
        COPY_FIRST_AVAILABE_FILE \
            parameter $PACK $STAGE $UNPACK
        while read KEY VALUE; do
            if [[ ! "$KEY" = "#"* ]]; then
                VALUE="${VALUE//$'\r'/}"
                if [[ "$VALUE" != "RESERVED" ]] && [[ ! -f $PACK/$VALUE ]]; then
                    COPY_FIRST_AVAILABE_FILE_BY_HARK_LINK \
                        $VALUE $PACK $STAGE $UNPACK
                fi
                [[ "$KEY" = "bootloader" ]] && BOOTLOADER="$VALUE"
            fi
        done <$PACK/package-file

        V $BIN/afptool -pack $PACK ${FIRMWARE}.tmp
        V $BIN/rkImageMaker -${CHIP_TYPE} $PACK/$BOOTLOADER ${FIRMWARE}.tmp $FIRMWARE -os_type:androidos
        rm -f ${FIRMWARE}.tmp

        echo
        BANNER "Packed firmware $FIRMWARE"
        ls -lh $FIRMWARE
    )
}

sdfirmware_pack () {
    (
        [[ "$1" ]] || USAGE "sdfirmware_pack <Firmware>"
        set -eu
        local FIRMWARE="$1"
        local OFFSET="0x2000"

        import_partitions_from_parameter $STAGE/parameter
        $BIN/rkcrc -p $STAGE/parameter $STAGE/parameter.img

        flash() {
            echo "--> Writing $1 at $(printf "0x%x" $2)"
            dd of=$FIRMWARE if="$STAGE/$1" seek="$2" conv=notrunc >/dev/null
        }
        flash idbloader.img 64
        flash parameter.img $((${OFFSET} + 0x0000))
        flash uboot.img     $((${OFFSET} + $PART_UBOOT_START))
        flash trust.img     $((${OFFSET} + $PART_TRUST_START))
        flash kernel.img    $((${OFFSET} + $PART_KERNEL_START))
        flash resource.img  $((${OFFSET} + $PART_RESOURCE_START))
        flash rootfs.img    $((${OFFSET} + $PART_BOOT_START))

        echo
        BANNER "Packed firmware $FIRMWARE"
        ls -lh $FIRMWARE
    )
}

firmware_compress () {
    (
        [[ "$1" ]] || USAGE "firmware_compress <Image>"
        set -e
        local FIRMWARE="$1"
        local FIRMWARE_7Z=${FIRMWARE%.*}.7z
        [[ -f "$FIRMWARE" ]] || F "Firmware '$FIRMWARE' not found!"

        [[ -f $FIRMWARE_7Z ]] && rm -f $FIRMWARE_7Z
        echo Compressing $FIRMWARE...
        #7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on $FIRMWARE_7Z $FIRMWARE
        7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=64m -ms=on -mmt=on $FIRMWARE_7Z $FIRMWARE
        md5sum $FIRMWARE_7Z

        echo
        BANNER "Compressed firmware to $FIRMWARE_7Z"
        ls -lh $FIRMWARE_7Z
    )
}

# Unpack boot.img
# If boot.img has "KRNL" signature, then unpack it as
#   $UNPACK/boot.img-raw
# Otherwise it is a ANDROID boot image, unpack it at
#   $UNPACK/boot.img.d
#     - kernel
#     - ramdisk.gpio.gz
#     - resource.img (optional)
boot_img_unpack () {
    (
        [[ "$1" ]] || USAGE "boot_img_unpack <boot.img|recovery.img>"
        set -e
        local BOOTIMG="$1"
        [[ -f $BOOTIMG ]] || BOOTIMG=$UNPACK/$BOOTIMG
        CHECK_FILE_EXISTS $BOOTIMG
        local MAGIC="$(dd if=out/unpack/boot.img bs=1 count=4 2>/dev/null)"

        if [[ "$MAGIC" == "KRNL" ]]; then
            $BIN/rkunpack $BOOTIMG
            echo
            BANNER "Unpacked $BOOTIMG at ${BOOTIMG}-raw"
            ls -l "${BOOTIMG}-raw"
        else
            local DIR=${BOOTIMG}.d
            CLEAN_MKDIR $DIR
            $BIN/unmkbootimg --input $BOOTIMG \
                             --kernel $DIR/kernel \
                             --ramdisk $DIR/ramdisk.cpio.gz \
                             --second $DIR/resource.img
            echo
            BANNER "Unpacked $BOOTIMG at $DIR"
            ls -l $DIR
        fi
    )
}

boot_img_pack_krnl () {
    (
        [[ "$1" ]] || USAGE "boot_img_pack_krnl <boot.img>"
        set -e
        local BOOTIMG="$1"
        local BOOTIMG_RAW="$(basename $BOOTIMG)-raw"
        [[ "$BOOTIMG" = *"/"* ]] || BOOTIMG=$STAGE/$BOOTIMG
        BOOTIMG_RAW=$(FIND_FIRST_AVAILABE_FILE "$BOOTIMG_RAW" $STAGE $UNPACK) || F "$BOOTIMG_RAW not found"
        V $BIN/rkcrc -k $BOOTIMG_RAW $BOOTIMG

        echo
        BANNER "Packed $BOOTIMG"
        ls -l $BOOTIMG
    )
}

boot_img_pack_android () {
    (
        [[ "$1" ]] || USAGE "boot_img_pack_android <boot.img|recovery.img>"
        local BOOTIMG="$1"
        [[ "$BOOTIMG" = *"/"* ]] || BOOTIMG=$STAGE/$BOOTIMG
        local DIR=$(basename ${BOOTIMG}).d
        local KERNEL RAMDISK RESOURCE
        echo "Finding files in out/stage/$DIR over out/unpack/$DIR"
        KERNEL=$(FIND_FIRST_AVAILABE_FILE kernel $STAGE/$DIR $UNPACK/$DIR) || F "kernel not found"
        RAMDISK=$(FIND_FIRST_AVAILABE_FILE ramdisk.cpio.gz $STAGE/$DIR $UNPACK/$DIR) || F "ramdisk.cpio.gz not found"
        RESOURCE=$(FIND_FIRST_AVAILABE_FILE resource.img $STAGE/$DIR $UNPACK/$DIR) || :

        LAZY_MKDIR $STAGE
        if [[ $RESOURCE ]]; then
            V $BIN/mkbootimg --output $BOOTIMG \
              --kernel $KERNEL \
              --ramdisk $RAMDISK \
              --second $RESOURCE
        else
            V $BIN/mkbootimg --output $BOOTIMG \
              --kernel $KERNEL \
              --ramdisk $RAMDISK
        fi

        echo
        BANNER "Packed $BOOTIMG"
        ls -l $BOOTIMG
    )
}

initrd_unpack () {
    (
        [[ $# -eq 2 ]] || USAGE "initrd_unpack <Initrd> <dir default in \$STAGE>"
        set -e
        local INITRD=$1
        local DESTDIR="$2"
        CHECK_FILE_EXISTS $INITRD
        [[ "$DESTDIR" = *"/"* ]] || DESTDIR=$STAGE/$DESTDIR
        CLEAN_MKDIR $DESTDIR
        zcat $INITRD | \
            ( cd $DESTDIR && cpio -idv --no-absolute-filenames )
    )
}

initrd_pack () {
    (
        [[ "$1" ]] || USAGE "initrd_pack <Initrd> <dir default in \$STAGE>"
        set -e
        local INITRD=$1
        local SRCDIR="$2"
        [[ "$SRCDIR" = *"/"* ]] || SRCDIR=$STAGE/$SRCDIR
        ( cd $SRCDIR &&
	            find . ! -path "./.git*" \
	                 ! -path "./README.md" \
	                 ! -path "./Makefile" \
                  | cpio -H newc -ov | gzip > $INITRD
        )
        truncate -s "%4" $INITRD
    )
}

within_boot_img () {
    (
        [[ $# -ge 3 ]] || USAGE "within_boot_img <boot_img> <dir default in \$STAGE> <func> [<func>...]"
        set -e
        local BOOTIMG="$1"
        local DIR="$2"
        local BASENAME=$(basename $BOOTIMG)
        [[ "$DIR" = *"/"* ]] || DIR=$STAGE/$DIR

        # Unpack boot img, initrd
        [[ -f $BOOTIMG ]] || BOOTIMG=$UNPACK/$BOOTIMG
        boot_img_unpack "$BOOTIMG"

        if [[ -f ${BOOTIMG}-raw ]]; then
            # krnl image
            initrd_unpack $UNPACK/boot.img-raw $DIR
        else
            # android image
            initrd_unpack ${BOOTIMG}.d/ramdisk.cpio.gz $DIR
        fi

        # Execute patches
        shift 2
        for FUNC in "$@"; do
            $FUNC
        done

        # Pack initrd, boot img
        if [[ -f ${BOOTIMG}-raw ]]; then
            # krnl image
            initrd_pack $STAGE/${BASENAME}-raw $DIR
            boot_img_pack_krnl $STAGE/${BASENAME}
        else
            # android image
            LAZY_MKDIR $STAGE/${BASENAME}.d
            initrd_pack $STAGE/${BASENAME}.d/ramdisk.cpio.gz $DIR
            boot_img_pack_android $STAGE/${BASENAME}
        fi
    )
}

within_ext4fs_img () {
    (
        [[ $# -ge 4 ]] || USAGE "within_ext4fs_img <system_img> <dir default in \$STAGE> <size enlarge in MB> <func> [<func>...]"
        set -e
        local SYSTEMIMG="$1"
        local DIR="$2"
        local ENLARGE_SIZE="$3"
        local BASENAME=$(basename $SYSTEMIMG)
        local NEWIMG=$STAGE/$BASENAME
        [[ "$SYSTEMIMG" = *"/"* ]] || SYSTEMIMG=$UNPACK/$SYSTEMIMG
        [[ "$DIR" = *"/"* ]] || DIR=$STAGE/$DIR
        [[ -f "$DIR" ]] && F "Mount point $DIR already exists!"
        mkdir -p $DIR

        # Copy system.img to stage dir
        V cp $SYSTEMIMG $NEWIMG
        V truncate -s +${ENLARGE_SIZE}M $NEWIMG
        V e2fsck -yf $NEWIMG
        V resize2fs $NEWIMG
        V e2fsck -yf $NEWIMG || V e2fsck -yf $NEWIMG

        # Mount
        V sudo mount $NEWIMG $DIR
        trap "sudo umount $DIR 2>/dev/null && rm $NEWIMG && rmdir $DIR && echo $NEWIMG removed due to error" EXIT

        # Execute patches
        shift 3
        for FUNC in "$@"; do
            V $FUNC
        done

        trap - EXIT
        V sudo umount $DIR
        rmdir $DIR

        echo
        BANNER "Patched $SYSTEMIMG to $NEWIMG"
    )
}

import_partitions_from_parameter () {
    [[ "$1" ]] || USAGE "import_partitions_from_parameter <parameter>"
    local PARAMETER_FILE="$1"
    local PARTITION NAME START LENGTH PARTNUM
    CHECK_FILE_EXISTS $PARAMETER_FILE

    # clear all PART_* variables first
    eval $(set | awk -v FS='=' -v VAR='^PART_\\w+$' '$1 ~ VAR { print "unset", $1 }')

    PARTNUM=1
	  for PARTITION in `cat ${PARAMETER_FILE} | grep '^CMDLINE' | sed 's/ //g' | sed 's/.*:\(0x.*[^)])\).*/\1/' | sed 's/,/ /g'`; do
        NAME=`echo ${PARTITION} | sed 's/\(.*\)(\(.*\))/\2/'`
        START=`echo ${PARTITION} | sed 's/.*@\(.*\)(.*)/\1/'`
        LENGTH=`echo ${PARTITION} | sed 's/\(.*\)@.*/\1/'`
        NAME=${NAME^^}
        eval PART_${NAME}_START=$(($START))
        if [[ $LENGTH == "-" ]]; then
            eval PART_${NAME}_LENGTH=-
        else
            eval PART_${NAME}_LENGTH=$(($LENGTH))
        fi
        eval PART_${NAME}_PARTNUM=$PARTNUM
        PARTNUM=$((PARTNUM+1))
	  done
}

flash_sdpartition () {
    (
        set -e
        [[ $# -eq 2 ]] || USAGE "flash_sdpartition <part> <image>"
        local PART="${1^^}"
        local IMAGE="$2"
        local PARAMETER SEEK DEST

        CHECK_FILE_EXISTS "$IMAGE"
        PARAMETER=$(FIND_FIRST_AVAILABE_FILE "parameter" $ROOT_DIR $STAGE) || F "parameter not found"
        import_partitions_from_parameter $STAGE/parameter
        SEEK="PART_${PART}_START"
        SEEK=${!SEEK}
        [[ -n "$SEEK" ]] || F "Partition ${PART} not found in $PARAMETER"
        SEEK=$((0x2000 + $SEEK)) # Partition is offset to 0x2000 in SD card
        DEST=${MMCBLK:-/dev/mmcblk0}
        I "Flashing $DEST (part $PART @ $(printf "0x%08x" $SEEK)) with $IMAGE..."
        V ${REMOTE_CMD:-} sudo dd if=$IMAGE of=$DEST seek=$SEEK conv=notrunc
     )
}

verify_partitions_in_parameter () {
    [[ "$1" ]] || USAGE "import_partitions_from_parameter <parameter>"
    local PARAMETER_FILE="$1"
    local PARTITION NAME START LENGTH
    local EXPECT_START LAST_START LAST_LENGTH
    CHECK_FILE_EXISTS $PARAMETER_FILE

    LAST_START=
    LAST_LENGTH=
    _hex() {
        printf "0x%08x" $1
    }
    for PARTITION in `cat ${PARAMETER_FILE} | grep '^CMDLINE' | sed 's/ //g' | sed 's/.*:\(0x.*[^)])\).*/\1/' | sed 's/,/ /g'`; do
        NAME=`echo ${PARTITION} | sed 's/\(.*\)(\(.*\))/\2/'`
        START=`echo ${PARTITION} | sed 's/.*@\(.*\)(.*)/\1/'`
        LENGTH=`echo ${PARTITION} | sed 's/\(.*\)@.*/\1/'`
        echo "$PARTITION"

        # check length align
        if [[ "$LENGTH" != "-" ]] && ((LENGTH % 0x2000 != 0)); then
            echo " - Length $(_hex $LENGTH) not aligned to 0x2000"
        fi

        # check offset
        if [[ -n "$LAST_START" ]]; then
            EXPECT_START=$((LAST_START + LAST_LENGTH))
            if ((EXPECT_START != START )); then
                echo " - Invaid start $(_hex $START), expects $(_hex $EXPECT_START)"
            fi
        fi
        LAST_START=$START
        LAST_LENGTH=$LENGTH
    done
}

clean () {
    [[ -d out ]] && V rm -rf out
    BANNER Cleaned
}

help () {
    grep -e '^[^ ]\+ () {$' $BIN/app.sh | sed 's, () {,,' | sort | grep -v "help\|^__"
}
