#!/bin/bash

set -euo pipefail

## root 로 실행한다.
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

source /rtu/.env/info
VPN_KEY=$(wg genkey)

#############
# WireGuard #
#############
mkdir -p /etc/wireguard
printf "${VPN_KEY}" > /etc/wireguard/rtu.key
printf "${VPN_KEY}" | wg pubkey > /etc/wireguard/rtu.pub

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = ${VPN_IP}/16
ListenPort = 51820
PrivateKey = ${VPN_KEY}

[Peer]
PublicKey = fQY2//jNlV80683/TYDTA2XXWKZISi638iSKAPKPpEw=
AllowedIPs = 10.123.255.0/24
Endpoint = 43.200.249.199:51820
PersistentKeepalive = 25
EOF

systemctl enable --now wg-quick@wg0

echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
echo "##################################################"
echo "이제 vpn 서버에서 아래 명령을 실행하세요."
echo "--------------------------------------------------"
echo "wg-add ${VPN_IP}/32 $(cat /etc/wireguard/rtu.pub)"
echo "wg-sync"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

