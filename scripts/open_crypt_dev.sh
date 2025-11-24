#!/bin/bash

#g3k_util read 50 | cryptsetup open /dev/mmcblk0p2 --key-file=- cryptroot
cat /work/scripts/keys/luks_master.key | cryptsetup open /dev/mmcblk0p2 --key-file=- cryptroot
mount /dev/mapper/cryptroot /mnt
