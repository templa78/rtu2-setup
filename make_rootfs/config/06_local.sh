#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.
#

# g3k.service
cat > /etc/systemd/system/g3k.service <<EOF
[Unit]
Description=g3k service (sync system clock from HSM very early)
DefaultDependencies=no
After=local-fs.target systemd-udev-settle.service
Before=sysinit.target time-sync.target multi-user.target

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/sbin/g3k_systemd
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF
sudo systemctl enable g3k.service


# rcm.service
cat > /etc/systemd/system/rcm.service <<EOF
[Unit]
Description=RTU Config Manager (UDS JSON API)
DefaultDependencies=no
After=local-fs.target systemd-udev-settle.service
Before=sysinit.target time-sync.target multi-user.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/sbin/rcm
Restart=on-failure
RestartSec=1s
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true

[Install]
WantedBy=sysinit.target
EOF
sudo systemctl enable rcm.service

# rtu-led-triggers.service
cat > /etc/systemd/system/rtu-led-triggers.service <<EOF
[Unit]
Description=RTU LED trigger setup
DefaultDependencies=no
After=sysinit.target
Before=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/rtu-led-triggers.sh

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable rtu-led-triggers.service
