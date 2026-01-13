#!/bin/bash

set -euo pipefail

mkdir -p /etc/iptables
cat > /etc/iptables/rules.v4 <<EOF
*filter
:INPUT DROP
:FORWARD DROP
:OUTPUT ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 43.200.249.199/32 -p udp --dport 51820 -j ACCEPT
-A INPUT -i wg0 -s 10.123.255.0/24 -p tcp --dport 8022 -j ACCEPT
-A INPUT -i wg0 -s 10.123.255.0/24 -p tcp --dport 8080 -j ACCEPT
-A INPUT -i wg0 -s 10.123.255.0/24 -p tcp --dport 8443 -j ACCEPT
-A INPUT -i usb0 -s 10.176.72.210/32 -p tcp --dport 8022 -j ACCEPT
-A INPUT -i usb0 -s 10.176.72.210/32 -p tcp --dport 8443 -j ACCEPT
-A INPUT -i wg0 -p icmp --icmp-type echo-request -j ACCEPT
-A OUTPUT -d 43.200.249.199/32 -p udp --dport 51820 -j ACCEPT
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

mkdir -p /etc/iptables.d
cat > /etc/iptables.d/00-base.rules <<EOF
*filter
:INPUT DROP
:FORWARD DROP
:OUTPUT ACCEPT

###### INPUT #####
# loopback 허용
-A INPUT -i lo -j ACCEPT

# established/related 허용
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
EOF

cat > /etc/iptables.d/10-system.rules <<EOF
###### INPUT #####
# VPN
-A INPUT -s 43.200.249.199/32 -p udp --dport 51820 -j ACCEPT

# VPN 대역에서 들어오는 ssh, web 허용
-A INPUT -i wg0 -s 10.123.255.0/24 -p tcp --dport 8022 -j ACCEPT
-A INPUT -i wg0 -s 10.123.255.0/24 -p tcp --dport 8080 -j ACCEPT
-A INPUT -i wg0 -s 10.123.255.0/24 -p tcp --dport 8443 -j ACCEPT

# usb0 대역에서 들어오는 ssh, web 허용
-A INPUT -i usb0 -s 10.176.72.210/32 -p tcp --dport 8022 -j ACCEPT
-A INPUT -i usb0 -s 10.176.72.210/32 -p tcp --dport 8443 -j ACCEPT

# wg0에서 들어오는 ping 허용
-A INPUT -i wg0 -p icmp --icmp-type echo-request -j ACCEPT

###### OUTPUT #####
# VPN
-A OUTPUT -d 43.200.249.199/32 -p udp --dport 51820 -j ACCEPT

# DNS
-A OUTPUT -d 8.8.8.8/32 -p udp --dport 53 -j ACCEPT
-A OUTPUT -d 8.8.8.8/32 -p tcp --dport 53 -j ACCEPT
-A OUTPUT -d 168.126.63.1/32 -p udp --dport 53 -j ACCEPT
-A OUTPUT -d 168.126.63.1/32 -p tcp --dport 53 -j ACCEPT

# NTP
-A OUTPUT -d 0.0.0.0/0 -p udp --dport 123 -j ACCEPT
EOF

rtu-iptables-apply.sh

source /rtu/.info
echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
echo "##################################################"
echo "russh 서버에서 아래 명령을 실행하여 다시 접속 테스트"
echo "방화벽이 엄격하게 적용되었으므로 종료하기 전에 반드시 테스트"
echo "--------------------------------------------------"
echo "russh ${ID} rtu"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
