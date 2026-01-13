#!/bin/bash

set -euo pipefail

### history 삭제
echo "history 삭제 !!!"
rm -rf /home/*/.bash_history
rm -rf /root/.bash_history
rm -rf /*.usr-is-merged

## 비밀번호 삭제
echo "비밀번호 삭제 !!!"
usermod -p '!' root
usermod -p '!' redas
usermod -p '!' pi

## redas 유저 삭제
echo "redas 유저 삭제 !!!"
userdel -r redas

## teamviewer 삭제
echo "teamviewer 삭제 !!!"
sleep 3
systemctl stop teamviewerd.service
systemctl disable teamviewerd.service
apt purge -y teamviewer-host
rm -rf /opt/teamviewer
rm -rf /etc/teamviewer
rm -rf /var/log/teamviewer

## 이 스크립트 제거
cd /root
rm -rf kpx-rtu1

echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
