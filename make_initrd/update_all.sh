#!/bin/bash

set -x

../scripts/open_crypt_dev.sh
../scripts/mount_sub.sh /mnt

mkdir -p /mnt/boot

INITRD_DIR=../images/initrds
rm -f ${INITRD_DIR}/*/initrd.img-6.1.119-rt45

cp ${INITRD_DIR}/ng3k/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ${INITRD_DIR}/ng3k
sleep 1

cp ${INITRD_DIR}/nohs/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ${INITRD_DIR}/nohs
sleep 1

cp ${INITRD_DIR}/nobr/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ${INITRD_DIR}/nobr
sleep 1

cp ${INITRD_DIR}/dist/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ${INITRD_DIR}/dist
sleep 1

# 비어 있으면 지우자.
rmdir /mnt/boot
sync

../scripts/umount_sub.sh /mnt
../scripts/close_crypt_dev.sh
sync
