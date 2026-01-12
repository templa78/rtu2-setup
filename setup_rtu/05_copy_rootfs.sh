#!/bin/bash

set -euxo pipefail

TARGET_DEV=/dev/mmcblk0
TARGET_PART1=${TARGET_DEV}p1
TARGET_PART2=${TARGET_DEV}p2

# 열기 (매핑명: cryptroot)
cryptsetup open ${TARGET_PART2} cryptroot  --key-file ../data/lm.bin

##################
# 이미지 복사
mkdir -p /mnt
mount /dev/mapper/cryptroot /mnt
tar -xf ../data/rootfs.img -C /mnt/
cp -a ../data/modules/* /mnt/usr/lib/modules/
sync
umount /mnt

cryptsetup close cryptroot
