#!/bin/bash

set -euo pipefail

## teamviewer 삭제
systemctl stop teamviewerd.service
systemctl disable teamviewerd.service

apt purge -y teamviewer-host
#apt autoremove -y --purge

rm -rf /opt/teamviewer
rm -rf /etc/teamviewer
rm -rf /var/log/teamviewer

## 이 스크립트 제거
cd /root
rm -rf kpx-rtu1

echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
