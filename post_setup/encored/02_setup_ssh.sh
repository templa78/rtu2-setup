#!/bin/bash

set -euo pipefail

## root 로 실행한다.
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

VPN_CLASS=10.123
source /rtu/.env/info

# 로그인 하기전에 다음 위치에 파일을 갖다 놓아야 한다. (나중에는 api로)
if [[ ! -f /etc/ssh/rtu-ca.pub ]]; then
  echo ""
  echo "FAIL: rtu-ca.pub 파일이 없습니다."
  echo ""
  echo "##################################################"
  echo "먼저 auth 서버에서 다음 명령으로 생성한 후 복사한다."
  echo "--------------------------------------------------"
  echo "gen_rtu ${RTU_ID}"
  echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

  exit 1
fi

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/auth.conf <<EOF
PasswordAuthentication no
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
ExecStartPost=/bin/bash -c '\
  sleep 3; \
  for i in $(seq 1 60); do \
    ping -c1 -W1 ${VPN_CLASS}.255.1 >/dev/null 2>&1 && exit 0; \
    sleep 1; \
  done; \
  exit 1'
EOF

systemctl restart ssh

echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
echo "##################################################"
echo "russh 서버에서 아래 명령을 실행하여 접속 테스트"
echo "--------------------------------------------------"
echo "russh ${RTU_ID} rtu ${VPN_IP}"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

