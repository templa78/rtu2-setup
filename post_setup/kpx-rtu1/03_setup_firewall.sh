#!/bin/bash

set -euo pipefail

VPN_SERVER_IP=13.124.5.213
VPN_CLASS=10.133

mkdir -p /etc/iptables
cat > /etc/iptables/rules.v4 <<EOF
*filter
:INPUT DROP
:FORWARD DROP
:OUTPUT ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s ${VPN_SERVER_IP}/32 -p udp --dport 51820 -j ACCEPT
-A INPUT -i wg0 -s ${VPN_CLASS}.255.0/24 -p tcp --dport 8022 -j ACCEPT
-A INPUT -i wg0 -s ${VPN_CLASS}.255.0/24 -p tcp --dport 8080 -j ACCEPT
-A INPUT -i wg0 -s ${VPN_CLASS}.255.0/24 -p tcp --dport 8443 -j ACCEPT
-A INPUT -i wg0 -p icmp --icmp-type echo-request -j ACCEPT
-A OUTPUT -d ${VPN_SERVER_IP}/32 -p udp --dport 51820 -j ACCEPT
-A OUTPUT -d 8.8.8.8/32 -p udp --dport 53 -j ACCEPT
-A OUTPUT -d 8.8.8.8/32 -p tcp --dport 53 -j ACCEPT
-A OUTPUT -d 168.126.63.1/32 -p udp --dport 53 -j ACCEPT
-A OUTPUT -d 168.126.63.1/32 -p tcp --dport 53 -j ACCEPT
-A OUTPUT -d 0.0.0.0/0 -p udp --dport 123 -j ACCEPT
COMMIT
EOF

cat > /etc/iptables/rules.v6 <<EOF
*filter
:INPUT DROP
:FORWARD DROP
:OUTPUT DROP
COMMIT
EOF

netfilter-persistent reload

source /rtu/.info
echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
echo "##################################################"
echo "russh 서버에서 아래 명령을 실행하여 다시 접속 테스트"
echo "방화벽이 엄격하게 적용되었으므로 종료하기 전에 반드시 테스트"
echo "--------------------------------------------------"
echo "russh ${ID} pi"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
