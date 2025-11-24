#!/bin/bash

TARGET=/mnt
if [ $# -gt 0 ]; then
    TARGET=$1
fi

umount ${TARGET}/dev/pts
umount --lazy ${TARGET}/dev
umount ${TARGET}/proc
umount ${TARGET}/sys
umount --lazy ${TARGET}/run
umount ${TARGET}/tmp
