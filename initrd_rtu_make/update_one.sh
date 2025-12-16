#!/bin/bash

set -x

TARGET=${1:-}

../scripts/open_crypt_dev.sh
../scripts/umount_sub.sh /mnt
../scripts/mount_sub.sh /mnt

mkdir -p /mnt/boot

cp ./initrds/${TARGET}/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ./initrds/${TARGET}/

# 비어 있으면 지우자.
rmdir /mnt/boot

../scripts/umount_sub.sh /mnt
../scripts/close_crypt_dev.sh

sync
sleep 1
