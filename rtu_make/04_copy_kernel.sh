#!/bin/bash

set -euxo pipefail

TARGET_DEV=/dev/mmcblk0
TARGET_PART1=${TARGET_DEV}p1
TARGET_PART2=${TARGET_DEV}p2

# 이미지 복사
mkdir -p /media
mount ${TARGET_PART1} /media
cp fitImage /media/
sync
umount /media
