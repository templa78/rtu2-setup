#!/bin/bash

set -ex

# linger 활성화 (로그인 없이도 사용자 systemd 서비스 실행 허용)
sudo loginctl enable-linger iderms

# 유저 패스워드 사용 안하기
#sudo usermod -p '!' rtu
#sudo usermod -p '!' iderms
