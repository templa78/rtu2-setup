#!/bin/bash

set -ex

cat > /etc/ssh/sshd_config <<EOF
AddressFamily inet
Include /etc/ssh/sshd_config.d/address.conf

HostKey /etc/ssh/ssh_host_ed25519_key
TrustedUserCAKeys /etc/ssh/rtu-ca.pub
AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u

AllowUsers rtu
AuthenticationMethods publickey
PubkeyAuthentication yes
PermitRootLogin no
PermitEmptyPasswords no
PasswordAuthentication no
AuthorizedKeysFile none
KbdInteractiveAuthentication no
UsePAM no

AcceptEnv LANG LC_*
EOF

mkdir -p /etc/ssh/auth_principals
cat > /etc/ssh/auth_principals <<EOF
rtu
EOF

VPN_IPADDR=$1
RTU_CA_PUB=$2

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/address.conf <<EOF
ListenAddress ${VPN_IPADDR}
EOF

cat > /etc/ssh/rtu-ca.pub <<EOF
${RTU_CA_PUB}
EOF
