#!/bin/bash

set -euxo pipefail

TARGET_DEV=/dev/mmcblk0
TARGET_PART1=${TARGET_DEV}p1
TARGET_PART2=${TARGET_DEV}p2

# GPT 생성 및 파티션
sgdisk --zap-all ${TARGET_DEV}
sgdisk --clear ${TARGET_DEV}
sgdisk -n 1:4MiB:+204MiB -t 1:8300 -c 1:"RTU-BOOT" ${TARGET_DEV}
sgdisk -n 2:0:0          -t 2:8300 -c 2:"RTU-CRYPT" ${TARGET_DEV}

# 포맷 (부트 파티션만)
mkfs.ext4 -F -L RTU-BOOT ${TARGET_PART1}

# LUKS2로 포맷 (관리용 패스프레이즈)
cryptsetup luksFormat --batch-mode --type luks2 ${TARGET_PART2} --key-file /work/scripts/keys/luks_master.key
sleep 1

# 자체 키 등록
g3k_util read 50 | cryptsetup luksAddKey --key-file=/work/scripts/keys/luks_master.key ${TARGET_PART2} --new-keyfile=-
sleep 1

# 열기 (매핑명: cryptroot)
cryptsetup open ${TARGET_PART2} cryptroot  --key-file /work/scripts/keys/luks_master.key
sleep 1

# 내부에 ext4 생성
mkfs.ext4 -F -L RTU-CRYPT /dev/mapper/cryptroot
sleep 1

cryptsetup close cryptroot

