#!/bin/bash

set -ex

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/auth.conf <<EOF
AuthenticationMethods publickey
TrustedUserCAKeys /etc/ssh/rtu-ca.pub
AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u
EOF

mkdir -p /etc/ssh/auth_principals
cat > /etc/ssh/auth_principals/iderms <<EOF
iderms
EOF
cat > /etc/ssh/auth_principals/rtu <<EOF
rtu
EOF

mkdir -p /etc/systemd/system/ssh.service.d
cat > /etc/systemd/system/ssh.service.d/override.conf <<EOF
[Service]
Restart=always
RestartSec=5s
StartLimitIntervalSec=0
StartLimitBurst=0
EOF

## resolve
systemctl stop systemd-resolved
systemctl disable systemd-resolved
rm -f /etc/resolv.conf
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 168.126.63.1
options timeout:1 attempts:1
EOF

systemctl disable systemd-networkd-wait-online.service
systemctl mask systemd-networkd-wait-online.service

mkdir -p /etc/systemd/system/wg-quick@wg0.service.d
cat > /etc/systemd/system/wg-quick@wg0.service.d/override.conf <<EOF
[Service]
Restart=on-failure
RestartSec=5s
StartLimitIntervalSec=0
StartLimitBurst=0
EOF
