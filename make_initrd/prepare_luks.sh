#!/bin/bash

INITRD_DIR=../images/initrds
rm -rf ${INITRD_DIR}

mkdir -p ${INITRD_DIR}/ng3k
mkdir -p ${INITRD_DIR}/nohs
mkdir -p ${INITRD_DIR}/nobr
mkdir -p ${INITRD_DIR}/dist
cp -a /home/iderms/Work/g3k/g3k_luks/data/g3k_luks_ng3k ${INITRD_DIR}/ng3k/g3k_luks
cp -a /home/iderms/Work/g3k/g3k_luks/data/g3k_luks_nohs ${INITRD_DIR}/nohs/g3k_luks
cp -a /home/iderms/Work/g3k/g3k_luks/data/g3k_luks_nobr ${INITRD_DIR}/nobr/g3k_luks
cp -a /home/iderms/Work/g3k/g3k_luks/data/g3k_luks_dist ${INITRD_DIR}/dist/g3k_luks
chown root:root ${INITRD_DIR}/ng3k/g3k_luks
chown root:root ${INITRD_DIR}/nohs/g3k_luks
chown root:root ${INITRD_DIR}/nobr/g3k_luks
chown root:root ${INITRD_DIR}/dist/g3k_luks
