#!/bin/bash

set -euxo pipefail

TARGET_DEV=/dev/sda
TARGET_PART1=${TARGET_DEV}1
TARGET_PART2=${TARGET_DEV}2

# 아래 GPT 가 아니라 MBR 방식으로 파티션을 만들어야 부팅이 가능하다!
fdisk ${TARGET_DEV} <<EOF
d

d

o

n
p
1

+4M

t
1

a

n
p
2



w
EOF


# GPT 생성 및 파티션
#sgdisk --zap-all ${TARGET_DEV}
#sgdisk --clear ${TARGET_DEV}
#sgdisk -n 1:0:+4MiB  -t 1:0700 -c 1:"RTU-BOOT" ${TARGET_DEV}
#sgdisk -n 2:0:0      -t 2:8300 -c 2:"RTU-ROOT" ${TARGET_DEV}
# bootable
#sgdisk -A 1:set:2 ${TARGET_DEV}

# 포맷 (부트 파티션만)
mkfs.vfat -F12 -n RTU-BOOT  ${TARGET_PART1}
mkfs.ext4 -F   -L RTU-ROOT  ${TARGET_PART2}

##################
# 이미지 복사
mount ${TARGET_PART1} /media
cp -a ../images/uboots/uboot_dev/* /media/
sync
umount /media

mount ${TARGET_PART2} /mnt
cp -a ./rootfs_setup/* /mnt/
cp -a ../images/kernels/kernel_dev/* /mnt/
mkdir -p /mnt/work
cp -a ../data /mnt/work/
cp -a ../setup_rtu /mnt/work/
sync
umount /mnt
