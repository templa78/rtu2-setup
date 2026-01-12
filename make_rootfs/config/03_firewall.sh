#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
#update-alternatives --set iptables-restore /usr/sbin/iptables-legacy-restore
#update-alternatives --set ip6tables-restore /usr/sbin/ip6tables-legacy-restore

mkdir -p /etc/iptables
cat > /etc/iptables/rules.v4 <<EOF
*filter
:INPUT DROP
:FORWARD DROP
:OUTPUT ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 0.0.0.0/0 -p udp --dport 51820 -j ACCEPT
-A INPUT -s 0.0.0.0/0 -p tcp --dport 8022 -j ACCEPT
-A INPUT -s 0.0.0.0/0 -p tcp --dport 8080 -j ACCEPT
-A INPUT -s 0.0.0.0/0 -p tcp --dport 8443 -j ACCEPT
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
-A INPUT -s 0.0.0.0/0 -p udp --dport 51820 -j ACCEPT
-A INPUT -s 0.0.0.0/0 -p tcp --dport 8022 -j ACCEPT
-A INPUT -s 0.0.0.0/0 -p tcp --dport 8080 -j ACCEPT
-A INPUT -s 0.0.0.0/0 -p tcp --dport 8443 -j ACCEPT
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
