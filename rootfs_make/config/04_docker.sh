#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

# subuid/subgid 설정
#echo "iderms:100000:65536" | tee -a /etc/subuid
#echo "iderms:100000:65536" | tee -a /etc/subgid

if [[ ! -d /iderms ]]; then
  mkdir -p /iderms
  chown iderms:iderms /iderms
fi

sudo -iu iderms bash <<'EOS'
mkdir -p /iderms/docker

# systemd override로 환경파일 주입
mkdir -p ~/.config/systemd/user/docker.service.d
cat > ~/.config/systemd/user/docker.service.d/override.conf <<EOF1
[Service]
Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_NET=pasta"
Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_PORT_DRIVER=implicit"
Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_DISABLE_HOST_LOOPBACK=false"
EOF1

# 데몬 설정(daemon.json)
mkdir -p ~/.config/docker
cat > ~/.config/docker/daemon.json <<EOF2
{
  "data-root": "/iderms/docker",
  "storage-driver": "overlay2",
  "iptables": false,
  "userland-proxy": false,
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
EOF2
EOS
