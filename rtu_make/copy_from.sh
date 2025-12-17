#!/bin/bash

set -euxo pipefail

#cryptsetup open ${SRC} cryptroot  --key-file /work/scripts/keys/luks_master.key
#mount /dev/mapper/cryptroot /mnt

SRC=/
DEST=./rootfs

mkdir -p ${DEST}

cp -a ./sys_rootfs/* ${DEST}/
cp -a ${SRC}/etc ${DEST}/
cp -a ${SRC}/home ${DEST}/
cp -a ${SRC}/iderms ${DEST}/
cp -a ${SRC}/opt ${DEST}/
cp -a ${SRC}/root ${DEST}/
cp -a ${SRC}/rtu ${DEST}/
cp -a ${SRC}/usr ${DEST}/
cp -a ${SRC}/var ${DEST}/

rm -rf ${DEST}/home/*/.bash_history
rm -rf ${DEST}/root/.bash_history
rm -rf ${DEST}/*.usr-is-merged

rm -rf ${DEST}/var/cache
rm -rf ${DEST}/var/crash
rm -rf ${DEST}/var/log
rm -rf ${DEST}/var/tmp/*
rm -rf ${DEST}/var/lib/dhcp
rm -rf ${DEST}/var/lib/systemd/random-seed

sync

#umount /mnt
#cryptsetup close cryptroot
