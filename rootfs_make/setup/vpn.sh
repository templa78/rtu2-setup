#!/bin/bash

set -ex

# TODO
#wg genkey | tee /etc/wireguard/rtu.key | wg pubkey | tee /etc/wireguard/rtu.pub
#chmod 600 /etc/wireguard/rtu.key
RTU_VPN_IP= #10.123.0.1
RTU_VPN_KEY=

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = $RTU_VPN_IP/16
PrivateKey = $RTU_PVN_KEY
DNS = 8.8.8.8

[Peer]
PublicKey = fQY2//jNlV80683/TYDTA2XXWKZISi638iSKAPKPpEw=
AllowedIPs = 10.123.255.0/24
Endpoint = 43.200.249.199:51820
PersistentKeepalive = 25
EOF

systemctl enable --now wg-quick@wg0

#연결
#wg-quick up wg0
#wg-quick down wg0
#mqtt -> "vpn_on" → exec("/usr/bin/sudo wg-quick up wg0")
#mqtt -> "vpn_off" → exec("/usr/bin/sudo wg-quick down wg0")
