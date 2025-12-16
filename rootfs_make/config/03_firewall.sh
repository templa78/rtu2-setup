#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

mkdir -p /etc/iptables
cat > /etc/iptables/rules.v4 <<EOF
*nat
:PREROUTING ACCEPT [32:3596]
:INPUT ACCEPT [6:588]
:OUTPUT ACCEPT [83:6235]
:POSTROUTING ACCEPT [83:6235]
:DOCKER - [0:0]
-A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
-A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
-A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
COMMIT

*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [37119:4809804]
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 10.123.255.0/24 -i wg0 -p tcp -m tcp --dport 8022 -j ACCEPT
-A INPUT -s 10.123.255.0/24 -i wg0 -p tcp -m tcp --dport 8080 -j ACCEPT
-A INPUT -s 10.123.255.0/24 -i wg0 -p tcp -m tcp --dport 8443 -j ACCEPT
-A INPUT -s 10.176.72.208/28 -i usb0 -p tcp -m tcp --dport 8443 -j ACCEPT
-A OUTPUT -d 8.8.8.8/32 -p udp -m udp --dport 53 -j ACCEPT
-A OUTPUT -d 8.8.4.4/32 -p udp -m udp --dport 53 -j ACCEPT
-A OUTPUT -d 168.126.63.1/32 -p udp -m udp --dport 53 -j ACCEPT
-A OUTPUT -d 168.126.63.2/32 -p udp -m udp --dport 53 -j ACCEPT
-A OUTPUT -d 10.123.0.1/32 -p udp -m udp --dport 51820 -j ACCEPT
-A OUTPUT -p udp -m udp --dport 123 -j ACCEPT
COMMIT
EOF

cat > /etc/iptables/rules.v6 <<EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
COMMIT
EOF

mkdir -p /etc/iptables.d
cat > /etc/iptables.d/00-base.rules <<EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]

###### INPUT #####
# loopback 허용
-A INPUT -i lo -j ACCEPT

# established/related 허용
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
EOF

cat > /etc/iptables.d/10-system.rules <<EOF
###### INPUT #####
# VPN 대역에서 들어오는 ssh, web 허용
-A INPUT -i wg0 -p tcp -s 10.123.255.0/24 --dport 8022 -j ACCEPT
-A INPUT -i wg0 -p tcp -s 10.123.255.0/24 --dport 8080 -j ACCEPT
-A INPUT -i wg0 -p tcp -s 10.123.255.0/24 --dport 8443 -j ACCEPT

# usb0 대역에서 들어오는 web 허용
-A INPUT -i usb0 -p tcp -s 10.176.72.208/28 --dport 8443 -j ACCEPT

###### OUTPUT #####
# DNS
-A OUTPUT -p udp -d 8.8.8.8 --dport 53 -j ACCEPT
-A OUTPUT -p udp -d 8.8.4.4 --dport 53 -j ACCEPT
-A OUTPUT -p udp -d 168.126.63.1 --dport 53 -j ACCEPT
-A OUTPUT -p udp -d 168.126.63.2 --dport 53 -j ACCEPT

# VPN
-A OUTPUT -p udp -d 10.123.0.1 --dport 51820 -j ACCEPT

# NTP
-A OUTPUT -p udp --dport 123 -j ACCEPT
EOF

cat > /etc/iptables.d/20-user.rules <<EOF
EOF

cat > /etc/systemd/system/rtu-iptables-loader.service <<EOF
[Unit]
Description=RTU iptables rule loader (base+system+user)
DefaultDependencies=no
Wants=network-pre.target
Before=network-pre.target
After=local-fs.target systemd-modules-load.service

# iptables-persistent(=netfilter-persistent)를 같이 쓰는 경우에는 그 뒤에 최종 정책을 올리도록 정렬
After=netfilter-persistent.service
Wants=netfilter-persistent.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/rtu-iptables-apply.sh --boot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl enable rtu-iptables-loader
