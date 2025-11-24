#!/bin/bash

set -x

../scripts/open_crypt_dev.sh
../scripts/mount_sub.sh /mnt

mkdir -p /mnt/boot

rm -f ./initrds/*/initrd.img-6.1.119-rt45

cp ./initrds/ng3k/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ./initrds/ng3k
sleep 1

cp ./initrds/nohs/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ./initrds/nohs
sleep 1

cp ./initrds/nobr/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ./initrds/nobr
sleep 1

cp ./initrds/dist/g3k_luks /mnt/usr/lib/cryptsetup/scripts/g3k_luks
chroot /mnt update-initramfs -c -k 6.1.119-rt45
mv /mnt/boot/initrd.img-6.1.119-rt45 ./initrds/dist
sleep 1

# 비어 있으면 지우자.
rmdir /mnt/boot
sync

../scripts/umount_sub.sh /mnt
../scripts/close_crypt_dev.sh
sync
