#!/bin/bash

set -euo pipefail

## root 로 실행한다.
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

source /rtu/.env/info
RTU_VPN_KEY=$(wg genkey)
PUBLIC_KEY="a6fELkGeBZKiZIae0IPopFmjuWmDe9rpyx79woFnRgs="
ALLOWED_IPS="10.133.255.0/24"
END_POINT="13.124.5.213:51820"

#############
# WireGuard #
#############
mkdir -p /etc/wireguard
printf "${RTU_VPN_KEY}" > /etc/wireguard/rtu.key
printf "${RTU_VPN_KEY}" | wg pubkey > /etc/wireguard/rtu.pub

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = ${VPN_IP}/16
ListenPort = 51820
PrivateKey = ${RTU_VPN_KEY}

[Peer]
PublicKey = ${PUBLIC_KEY}
AllowedIPs = ${ALLOWED_IPS}
Endpoint = ${END_POINT}
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

