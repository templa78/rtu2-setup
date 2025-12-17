#!/bin/bash

set -ex

RTU_VPN_IP=$1

# 로그인 하기전에 다음 위치에 파일을 갖다 놓아야 한다. (나중에는 api로)
# /etc/ssh/rtu-ca.pub

#../scripts/open_crypt_dev.sh
cp setup/post.sh /mnt/

chroot /mnt /post.sh ${RTU_VPN_IP}

#../scripts/close_crypt_dev.sh
