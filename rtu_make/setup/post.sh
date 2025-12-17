#!/bin/bash

set -ex

## root 로 실행한다.

# 로그인 하기전에 다음 위치에 파일을 갖다 놓아야 한다. (나중에는 api로)
# /etc/ssh/rtu-ca.pub

RTU_VPN_IP=$1
RTU_VPN_KEY=$(wg genkey)

#############
# WireGuard #
#############
mkdir -p /etc/wireguard
printf "${RTU_VPN_KEY}" > /etc/wireguard/rtu.key
printf "${RTU_VPN_KEY}" | wg pubkey > /etc/wireguard/rtu.pub

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = ${RTU_VPN_IP}/16
PrivateKey = ${RTU_VPN_KEY}

[Peer]
PublicKey = fQY2//jNlV80683/TYDTA2XXWKZISi638iSKAPKPpEw=
AllowedIPs = 10.123.255.0/24
Endpoint = 43.200.249.199:51820
PersistentKeepalive = 25
EOF

systemctl enable wg-quick@wg0

## 비밀번호 제거
usermod -p '!' rtu
usermod -p '!' iderms
