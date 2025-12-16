#!/bin/bash

set -euxo pipefail

TARGET_DEV=/dev/mmcblk0
TARGET_PART1=${TARGET_DEV}p1
TARGET_PART2=${TARGET_DEV}p2

# 열기 (매핑명: cryptroot)
cryptsetup open ${TARGET_PART2} cryptroot  --key-file /work/scripts/keys/luks_master.key

##################
# 이미지 복사
mkdir -p /mnt
mount /dev/mapper/cryptroot /mnt
tar -xzf rootfs.tar.gz -C /mnt/
sync
umount /mnt

cryptsetup close cryptroot
