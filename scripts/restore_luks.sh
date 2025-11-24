#!/bin/bash

set -euo pipefail

# brick 여부 확인
key=$(g3k_util read 50 | xxd -p -l 30)
echo "[${key}]"
if [ "${key}" = "000000000000000000000000000000000000000000000000000000000000" ]; then
	echo "BRICKed_!!"
else
	echo "GOOD~!"
	exit 0
fi
sleep 1

# g3k 새로운 키 생성
echo "새로운 키 생성"
g3k_util read -1 | g3k_util write 50
sleep 1

# LUKS 키 내역 보기
cryptsetup luksDump /dev/mmcblk0p2

echo "삭제할 키 입력 : "
read keySlot

# LUKS 키 삭제
echo "키 삭제 진행"
cryptsetup luksKillSlot --key-file=keys/luks_master.key /dev/mmcblk0p2 ${keySlot}

# LUKS 새 키 등록
echo "새로운 키 등록"
g3k_util read 50 | cryptsetup luksAddKey --key-file=keys/luks_master.key /dev/mmcblk0p2

