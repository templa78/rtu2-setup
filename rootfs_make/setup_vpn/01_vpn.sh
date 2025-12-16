#!/bin/bash

set -ex

VPN_RTU_IP=$1
VPN_RTU_KEY=$2

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = ${VPN_RTU_IP}/16
PrivateKey = ${VPN_RTU_KEY}
DNS = 8.8.8.8

[Peer]
PublicKey = fQY2//jNlV80683/TYDTA2XXWKZISi638iSKAPKPpEw=
AllowedIPs = 10.123.255.0/24
Endpoint = 43.200.249.199:51820
PersistentKeepalive = 25
EOF

systemctl enable --now wg-quick@wg0
