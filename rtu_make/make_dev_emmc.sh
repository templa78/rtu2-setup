#!/bin/bash

set -euxo pipefail

# g3k 설정
#g3k_init || true
#/usr/local/sbin/g3k_setrtc

TARGET_DEV=/dev/mmcblk0
TARGET_PART1=${TARGET_DEV}p1

# GPT 생성 및 파티션
sgdisk --zap-all ${TARGET_DEV}
sgdisk --clear ${TARGET_DEV}
sgdisk -n 1:0:0      -t 1:8300 -c 1:"RTU-ROOT" ${TARGET_DEV}

# 포맷 (부트 파티션만)
mkfs.ext4 -F   -L RTU-ROOT   ${TARGET_PART1}

##################
# 이미지 복사
mount ${TARGET_PART1} /mnt
#rsync -av rootfs/ /mnt/
tar -xzf ../rootfs_make/rootfs_inst.tar.gz -C /mnt/
sync
umount /mnt

