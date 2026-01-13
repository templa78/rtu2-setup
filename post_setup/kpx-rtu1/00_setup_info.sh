#!/bin/bash

set -euo pipefail

## root 로 실행한다.
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

if [[ "/root/kpx-rtu1" != $(pwd) ]]; then
  echo "/root/kpx-rtu1 디렉토리에서 실행하세요."
  exit 1
fi
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

if [[ "/root/kpx-rtu1" != ${SCRIPT_DIR} ]]; then
  echo "/root/kpx-rtu1 디렉토리에서 ./00-setup-pre.sh 실행하세요."
  exit 1
fi

## VPN에서 사용할 IP를 인자로 받는다
if [[ $# -eq 0 ]]; then
  echo "Usage: 00_setup_pre.sh <RTU_ID> <VPN_IP>"
  exit
fi

RTU_ID=$1
VPN_IP=$2

mkdir -p /rtu
cat > /rtu/.info <<EOF
DOMAIN=kpx
ID=${RTU_ID}
IP=${VPN_IP}
EOF
chmod 400 /rtu/.info

# security option
rm -f /etc/hosts.allow
rm -f /etc/hosts.deny
mkdir -p /etc/profile.d
cat > /etc/profile.d/security.sh <<EOF
unset HISTFILE
export TMOUT=600
EOF

## apt 정리
echo "#### apt 정리 ####"
set -x
rm -f /etc/apt/sources.list.d/teamviewer.list
rm -f /etc/apt/sources.list.d/zymbit.list
sed -i \
  's|http://raspbian.raspberrypi.org/raspbian|http://legacy.raspbian.org/raspbian|g' \
  /etc/apt/sources.list
apt-get update --allow-releaseinfo-change
apt-get update
set +x

## .vimrc 복사
cp data/.vimrc /root/
cp data/.vimrc /home/pi/
chown pi:pi /home/pi/.vimrc

## wireguard 설치
cp data/wg /usr/local/sbin/
cp data/wg-go /usr/local/sbin/
cp data/wg-up /usr/local/sbin/
cp data/wg-down /usr/local/sbin/
cp data/wg-quick@.service /etc/systemd/system/
mkdir -p /etc/wireguard
chmod 700 /etc/wireguard

## socat 설치
apt-get install -y socat

## iptables-persistent 설치
apt-get install -y iptables-persistent

echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
