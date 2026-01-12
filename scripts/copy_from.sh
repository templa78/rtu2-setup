#!/bin/bash

set -euxo pipefail

SRC=/
DEST=../output/rootfs
if [[ $# -eq 1 ]]; then
  DEST=$1
fi

#cryptsetup open ${SRC} cryptroot  --key-file /work/scripts/keys/luks_master.key
#mount /dev/mapper/cryptroot /mnt

mkdir -p ${DEST}

cp -a ../images/sys_rootfs/* ${DEST}/
cp -a ${SRC}/etc ${DEST}/
cp -a ${SRC}/home ${DEST}/
cp -a ${SRC}/iderms ${DEST}/
cp -a ${SRC}/opt ${DEST}/
cp -a ${SRC}/root ${DEST}/
cp -a ${SRC}/rtu ${DEST}/
cp -a ${SRC}/usr ${DEST}/
cp -a ${SRC}/var ${DEST}/

#modules는 fitImage(kernel,dtb,initrd) 와 함께 따로 처리한다
rm -rf ${DEST}/usr/lib/modules/*
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
