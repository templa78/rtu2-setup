#!/bin/bash

set -euxo pipefail

echo ""
echo "###   fuse uboot   ###"
echo ""

SRC_DIR=./uboot
if [ $# -gt 0 ]; then
    SRC_DIR=$1
fi

echo 0 > /sys/block/mmcblk0boot0/force_ro
dd if=/dev/urandom of=/dev/mmcblk0boot0 bs=512 count=8192
dd if=${SRC_DIR}/tiboot3.bin of=/dev/mmcblk0boot0 seek=0
dd if=${SRC_DIR}/tispl.bin of=/dev/mmcblk0boot0 seek=1024
dd if=${SRC_DIR}/u-boot.img of=/dev/mmcblk0boot0 seek=5120

mmc bootpart enable 1 1 /dev/mmcblk0boot0
sleep 1

mmc bootbus set single_backward x1 x8  /dev/mmcblk0boot0
sleep 1

mmc hwreset enable /dev/mmcblk0
sleep 1

echo ""
echo ">>> done <<<"
echo ""
