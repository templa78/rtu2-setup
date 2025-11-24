#!/bin/bash

set -x

TARGET=rootfs

../scripts/mount_sub.sh ${TARGET}

cp install.sh ${TARGET}/
chroot ${TARGET} /install.sh
rm ${TARGET}/install.sh

../scripts/umount_sub.sh ${TARGET}

cp -a overlayfs/* ${TARGET}/
