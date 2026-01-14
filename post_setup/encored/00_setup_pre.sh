#!/bin/bash

set -euo pipefail

## root 로 실행한다.
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

## VPN에서 사용할 IP를 인자로 받는다
if [[ $# -eq 0 ]]; then
  echo "Usage: 00_setup_pre.sh <RTU_ID> <VPN_IP>"
  exit
fi

RTU_ID=$1
VPN_IP=$2

mkdir -p /rtu/.env
cat > /rtu/.env/info <<EOF
DOMAIN=encored
RTU_ID=${RTU_ID}
VPN_IP=${VPN_IP}
EOF
chmod 400 /rtu/.env/info
cat > /rtu/.env/arch <<EOF
OS=ubuntu
OS_VERSION=24.04.3
KERNEL=6.1
KERNELV=6.1.119-rt45
ARCH=armv8-a
EOF
chmod 400 /rtu/.env/arch

echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
