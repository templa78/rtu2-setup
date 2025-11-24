#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

export DEBIAN_FRONTEND=noninteractive

## 필수 패키지들을 설치한다
apt-get -y update
apt-get -y upgrade

# 반드시 필요 (기본 부팅)
apt-get install -y systemd systemd-sysv udev kmod

# 반드시 필요 (구성)
apt-get install -y iproute2 gpiod sudo wireguard openssh-server logrotate
apt-get install -y iptables libxtables12 ufw

# 편의사항
apt-get install -y vim netcat-openbsd iputils-ping 


# security option
mkdir -p /etc/profile.d
cat > /etc/profile.d/security.sh <<EOF
unset HISTFILE
export TMOUT=900
EOF

# 타임존을 Asia/Seoul 로 설정
apt-get install -y tzdata
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
echo "Asia/Seoul" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
#timedatectl
sleep 1
#----------

# ko_KR.UTF-8 로케일 활성화
apt-get install -y locales
sed -i 's/^\s*#\s*\(ko_KR\.UTF-8\s\+UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^\s*#\s*\(en_US\.UTF-8\s\+UTF-8\)/\1/' /etc/locale.gen
locale-gen
update-locale LANG=ko_KR.UTF-8 LC_CTYPE=ko_KR.UTF-8 LC_MESSAGES=ko_KR.UTF-8
cat /etc/default/locale
sleep 1
#----------

## 기본 쉘 dash => bash로 변경
echo "dash dash/sh boolean false" | debconf-set-selections
dpkg-reconfigure -f noninteractive dash
target=$(readlink -f /bin/sh)
echo "Current /bin/sh -> ${target}"
sleep 1
#----------

### 그룹,계정 추가
useradd -m -U -s /bin/bash --skel /dev/null -K UMASK=077 iderms
useradd -m -U -s /bin/bash --skel /dev/null -K UMASK=077 rtu
groupadd gpio
usermod -aG dialout,gpio iderms

mkdir -p /etc/sudoers.d
cat > /etc/sudoers.d/rtu-sudoers <<EOF
rtu ALL=(ALL) NOPASSWD:ALL
EOF

# linger 활성화 (로그인 없이도 사용자 systemd 서비스 실행 허용)
loginctl enable-linger iderms

