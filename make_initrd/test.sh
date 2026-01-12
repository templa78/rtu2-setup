#!/bin/bash

set -exuo pipefail

if ! ../images/initrds/nohs/g3k_luks | cryptsetup open /dev/mmcblk0p2 --type luks --allow-discards --key-file=- cryptroot; then
	echo "cryptsetup open failed"
else
	echo "SUCCESS"
fi
