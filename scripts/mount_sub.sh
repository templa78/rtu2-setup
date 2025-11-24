#!/bin/bash

TARGET=/mnt
if [ $# -gt 0 ]; then
	TARGET=$1
fi

mkdir -p ${TARGET}/dev/{pts,shm}
mkdir -p ${TARGET}/proc
mkdir -p ${TARGET}/sys
mkdir -p ${TARGET}/run
mkdir -p ${TARGET}/tmp

mount --bind /dev  ${TARGET}/dev
mount --bind /dev/pts  ${TARGET}/dev/pts
mount --bind /proc ${TARGET}/proc
mount --bind /sys  ${TARGET}/sys
mount --bind /run  ${TARGET}/run
mount --bind /tmp  ${TARGET}/tmp
