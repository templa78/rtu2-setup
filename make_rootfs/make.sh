#!/bin/bash

set -euxo pipefail

TARGET_DIR=rootfs
if [ $# -gt 0 ]; then
	TARGET_DIR=$1
fi

# TARGET_DIR (=rootfs) 준비되어 있다고 가정한다.
if [ -e "${TARGET_DIR}" ]; then
	mv ${TARGET_DIR} ${TARGET_DIR}_$(date +%y%m%d_%H%M)
fi
mkdir -p ${TARGET_DIR}

tar -xzf ../images/ubuntu_base_24.04.3-arm64.tar.gz -C ${TARGET_DIR}
#cp -a ../images/kernels/kernel_dev/usr ${TARGET_DIR}/
cp -a ../images/firmware ${TARGET_DIR}/usr/lib/
cp -a ../images/opt ${TARGET_DIR}/

###################################
# chroot 로 계정, 패키지들 설치한다
###################################

../scripts/mount_sub.sh ${TARGET_DIR}

cp -f install.sh ${TARGET_DIR}/tmp/
chroot ${TARGET_DIR} /tmp/install.sh

## install 후 복사해야 하는 파일들
cp -a postfs/* ${TARGET_DIR}/

cp -a config ${TARGET_DIR}/tmp/
chroot ${TARGET_DIR} /tmp/config/01_base.sh
chroot ${TARGET_DIR} /tmp/config/02_network.sh
chroot ${TARGET_DIR} /tmp/config/03_firewall.sh
chroot ${TARGET_DIR} /tmp/config/04_docker.sh
chroot ${TARGET_DIR} /tmp/config/05_mongo.sh
chroot ${TARGET_DIR} /tmp/config/06_local.sh

../scripts/umount_sub.sh ${TARGET_DIR}

# 필요없는 파일은 지운다.
./remove_cache.sh

sync
