#!/bin/bash

set -euo pipefail

echo "history 제거"
rm -rf /home/*/.bash_history
rm -rf /root/.bash_history
rm -rf /*.usr-is-merged

echo "cache 제거"
rm -rf /var/cache
rm -rf /var/crash
rm -rf /var/log
rm -rf /var/lib/dhcp
rm -rf /var/lib/systemd/random-seed

echo "비밀번호 제거"
usermod -p '!' rtu
usermod -p '!' iderms

echo ""
echo "!!!!! SUCCESS !!!!"
echo ""
