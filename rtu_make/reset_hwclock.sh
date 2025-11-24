#!/bin/bash

set -euxo pipefail

echo timeout 3 ntpdate -s time.bora.net
timeout 3 ntpdate -s time.bora.net
if [ "$?" != 0 ]; then
    echo timeout 3 ntpdate -s zero.bora.net
    timeout 3 ntpdate -s zero.bora.net
    if [ "$?" != 0 ]; then
        echo timeout 3 ntpdate -s time.nist.gov
        timeout 3 ntpdate -s time.nist.gov
        if [ "$?" != 0 ]; then
            echo "fail"
            exit 1
        fi
    fi
fi

echo hwclock -u --systohc
hwclock -u --systohc

/usr/bin/g3k_setrtc
