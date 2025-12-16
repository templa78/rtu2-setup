#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

export DEBIAN_FRONTEND=noninteractive

# security option
mkdir -p /etc/profile.d
cat > /etc/profile.d/security.sh <<EOF
unset HISTFILE
export TMOUT=900
EOF

## 기본 쉘 dash => bash로 변경
echo "dash dash/sh boolean false" | debconf-set-selections
dpkg-reconfigure -f noninteractive dash
ln -sf bash /bin/sh
target=$(readlink -f /bin/sh)
echo "Current /bin/sh -> ${target}"
sleep 1
#----------

## 그룹,계정 추가
useradd -m -U -s /bin/bash --skel /dev/null -K UMASK=077 iderms
useradd -m -U -s /bin/bash --skel /dev/null -K UMASK=077 rtu
groupadd gpio
usermod -aG dialout,gpio iderms
chmod 700 /home/rtu
chmod 700 /home/iderms

## vimrc
cp -a /root/.vimrc /home/rtu/.vimrc
cp -a /root/.vimrc /home/iderms/.vimrc
chown rtu:rtu /home/rtu/.vimrc
chown iderms:iderms /home/iderms/.vimrc

mkdir -p /etc/sudoers.d
cat > /etc/sudoers.d/rtu-sudoers <<EOF
rtu ALL=(ALL) NOPASSWD:ALL
EOF

## 비밀번호 설정 (나중에 삭제)
passwd rtu <<EOF
Dlszhdjem_edev
Dlszhdjem_edev
EOF
passwd iderms <<EOF
Dlszhdjem_edev
Dlszhdjem_edev
EOF
# 나중에 제거
#usermod -p '!' rtu
#usermod -p '!' iderms

