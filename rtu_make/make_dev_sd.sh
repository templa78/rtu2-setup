#!/bin/bash

set -euxo pipefail

g3k_init || true

TARGET_DEV=/dev/sda
TARGET_PART1=${TARGET_DEV}1
TARGET_PART2=${TARGET_DEV}2

fdisk ${TARGET_DEV}
d

d

o                # 새 MBR 파티션 테이블 생성

n                # 새 파티션
p                # primary
1                # 파티션 번호 1
<Enter>          # 시작 섹터 (기본값)
+4M              # 크기 4MiB

t                # 타입 변경
1                # FAT12

a                # 부트 플래그 활성화 (sda1 선택됨)

n                # 새 파티션
p                # primary
2                # 파티션 번호 2
<Enter>          # 시작 섹터 (기본값)
<Enter>          # 끝까지 사용

w                # 저장 후 종료


# GPT 생성 및 파티션
#sgdisk --zap-all ${TARGET_DEV}
#sgdisk --clear ${TARGET_DEV}
#sgdisk -n 1:0:+8MiB  -t 1:ef00 -c 1:"RTU-LOADER" ${TARGET_DEV}
#sgdisk -n 2:0:0      -t 2:8300 -c 2:"RTU-ROOT" ${TARGET_DEV}
# bootable
#sgdisk -A 1:set:2 ${TARGET_DEV}

# 포맷 (부트 파티션만)
mkfs.vfat -F12 -n RTU-LOADER ${TARGET_PART1}
mkfs.ext4 -F   -L RTU-ROOT   ${TARGET_PART2}

##################
# 이미지 복사
mount ${TARGET_PART1} /media
rsync -av /work/images/uboots/uboot_verbosse/ /media/
sync
umount /media

mount ${TARGET_PART2} /mnt
rsync -av rootfs/ /mnt/
sync
umount /mnt
