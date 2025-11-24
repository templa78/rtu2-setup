#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

# 필수 패키지
apt-get install -y ca-certificates curl gnupg
apt-get install -y uidmap slirp4netns fuse-overlayfs dbus-user-session

# Docker apt repo 등록
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
. /etc/os-release
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
 https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

# 패키지 설치
apt-get install -y docker-ce docker-ce-cli containerd.io docker-ce-rootless-extras passt

# subuid/subgid 설정
echo "iderms:100000:65536" | tee -a /etc/subuid
echo "iderms:100000:65536" | tee -a /etc/subgid

sudo -iu iderms bash <<'EOS'
mkdir -p /iderms/docker

# systemd override로 환경파일 주입
mkdir -p ~/.config/systemd/user/docker.service.d
cat > ~/.config/systemd/user/docker.service.d/override.conf <<EOF1
[Service]
export ROOTLESSKIT_NET=pasta
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

dockerd-rootless-setuptool.sh install
EOS
