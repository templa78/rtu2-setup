#!/bin/bash

set -ex

RTU_VPN_IP=$1
RTU_CA_PUB=$2

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/vpn.conf <<EOF
ListenAddress ${RTU_VPN_IP}
AuthenticationMethods publickey
TrustedUserCAKeys /etc/ssh/rtu-ca.pub
AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u
EOF

cat > /etc/ssh/rtu-ca.pub <<EOF
${RTU_CA_PUB}
EOF

mkdir -p /etc/ssh/auth_principals
cat > /etc/ssh/auth_principals/iderms <<EOF
iderms
EOF
cat > /etc/ssh/auth_principals/rtu <<EOF
rtu
EOF

mkdir -p /etc/systemd/system/ssh.service.d
cat > /etc/systemd/system/ssh.service.d/after_wg.conf <<EOF
[Unit]
After=wg-quick@wg0.service
Requires=wg-quick@wg0.service

[Service]
Restart=always
RestartSec=5s
StartLimitIntervalSec=0
StartLimitBurst=0
EOF

systemctl daemon-reload
systemctl restart ssh.service
