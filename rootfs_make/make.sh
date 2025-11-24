#!/bin/bash

set -ex

TARGET_DIR=rootfs
if [ $# -gt 0 ]; then
	TARGET_DIR=$1
fi

# TARGET_DIR (=rootfs) 준비되어 있다고 가정한다.
if [ -e "${TARGET_DIR}" ]; then
	mv ${TARGET_DIR} ${TARGET_DIR}_$(date +%y%m%d_%H%M)
fi
mkdir -p ${TARGET_DIR}
tar -xzf ubuntu_base_24.04.3-arm64.tar.gz -C ${TARGET_DIR}
cp -a ../images/kernel/* ${TARGET_DIR}/
cp -a ../images/firmware ${TARGET_DIR}/usr/lib/
cp -a ../images/opt ${TARGET_DIR}/
#cp -a crzfs/* ${TARGET_DIR}/

###################################
# chroot 로 계정, 패키지들 설치한다
###################################

../scripts/mount_sub.sh ${TARGET_DIR}
echo encored > ${TARGET_DIR}/etc/hostname
echo 127.0.0.1 localhost > ${TARGET_DIR}/etc/hosts
echo 127.0.0.1 encored >> ${TARGET_DIR}/etc/hosts
echo "nameserver 8.8.8.8" >> ${TARGET_DIR}/etc/resolv.conf

cp install_base.sh ${TARGET_DIR}/
chroot ${TARGET_DIR} /install_base.sh
rm ${TARGET_DIR}/install_base.sh

../scripts/umount_sub.sh ${TARGET_DIR}

#####################################
# 추가 설정파일들 덮어쓴다.
#####################################
#cp -a idermsfs/* ${TARGET_DIR}/

# 필요없는 파일은 지운다.
./remove_cache.sh
