#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

echo encored > ${TARGET_DIR}/etc/hostname
echo 127.0.0.1 localhost > ${TARGET_DIR}/etc/hosts
echo 127.0.0.1 encored >> ${TARGET_DIR}/etc/hosts
echo "nameserver 8.8.8.8" >> ${TARGET_DIR}/etc/resolv.conf

export DEBIAN_FRONTEND=noninteractive

## 필수 패키지들을 설치한다
apt-get -y update
apt-get -y upgrade

# 반드시 필요 (기본 부팅)
apt-get install -y systemd systemd-sysv udev kmod

# 반드시 필요 (구성)
apt-get install -y netplan.io iproute2 gpiod sudo wireguard openssh-server logrotate
apt-get install -y iptables iptables-persistent

# 편의사항
apt-get install -y vim netcat-openbsd iputils-ping 

#####################
# 타임존 설치 및 설정 (Asia/Seoul)
#####################
apt-get install -y tzdata
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
echo "Asia/Seoul" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
#timedatectl
sleep 1
#=====================

#####################
# 로케일 설치 및 설정 (ko_KR.UTF-8)
#####################
apt-get install -y locales
sed -i 's/^\s*#\s*\(ko_KR\.UTF-8\s\+UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^\s*#\s*\(en_US\.UTF-8\s\+UTF-8\)/\1/' /etc/locale.gen
locale-gen
update-locale LANG=ko_KR.UTF-8 LC_CTYPE=ko_KR.UTF-8 LC_MESSAGES=ko_KR.UTF-8
cat /etc/default/locale
sleep 1
#=====================

##############
## DOCKER 설치
##############
# 필수 패키지
apt-get install -y ca-certificates curl gnupg
apt-get install -y uidmap slirp4netns fuse-overlayfs dbus-user-session

# Docker apt repo 등록
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
. /etc/os-release
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
 https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

# 패키지 설치
apt-get install -y docker-ce docker-ce-cli containerd.io docker-ce-rootless-extras passt
#=====================
