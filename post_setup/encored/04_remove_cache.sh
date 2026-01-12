#!/bin/bash

set -euo pipefail

TARGET_DIR=rootfs
if [ $# -gt 0 ]; then
    TARGET_DIR=$1
fi

rm -rf ${TARGET_DIR}/home/*/.bash_history
rm -rf ${TARGET_DIR}/root/.bash_history
rm -rf ${TARGET_DIR}/*.usr-is-merged

rm -rf ${TARGET_DIR}/var/cache
rm -rf ${TARGET_DIR}/var/crash
rm -rf ${TARGET_DIR}/var/log
rm -rf ${TARGET_DIR}/var/lib/dhcp
rm -rf ${TARGET_DIR}/var/lib/systemd/random-seed

## 비밀번호 제거
usermod -p '!' rtu
usermod -p '!' iderms

echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
