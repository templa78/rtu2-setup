#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.
#
### 그룹,계정 추가
useradd -M -U -r -d /rtu/mongodb -s /usr/sbin/nologin mongodb

mkdir -p /usr/local/bin
cat > /usr/local/bin/mongo <<EOF
#!/bin/bash
/opt/mongodb/current/bin/mongo 10.224.92.71
EOF

# mongodb.conf
mkdir -p /rtu/mongodb/config
cat > /rtu/mongodb/config/mongodb.conf <<EOF
storage:
  dbPath: /rtu/mongodb/data
  journal:
    enabled: true

systemLog:
  destination: file
  path: /rtu/mongodb/log/mongod.log
  logAppend: true

net:
  port: 27017
  bindIp: 10.224.92.71

processManagement:
  pidFilePath: /run/mongodb/mongod.pid
  timeZoneInfo: /usr/share/zoneinfo
EOF

## NOTE : 위에 security 적용(?)
#security:
#  authorization: enabled


# mongodb.service
mkdir -p /rtu/mongodb/service
cat > /rtu/mongodb/service/mongodb.service <<EOF
[Unit]
Description=MongoDB Database Server
Documentation=https://docs.mongodb.com/manual
After=network-online.target

[Service]
User=mongodb
Group=mongodb
ExecStart=/opt/mongodb/current/bin/mongod --config /rtu/mongodb/config/mongodb.conf
PIDFile=/run/mongodb/mongod.pid
RuntimeDirectory=mongodb
RuntimeDirectoryMode=0755
LimitNOFILE=64000
TimeoutStopSec=15
Restart=on-failure

# 보안 하드닝
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
ProtectKernelTunables=true
ProtectControlGroups=true
ProtectKernelModules=true
LockPersonality=true
UMask=0027

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /rtu/mongodb/data
mkdir -p /rtu/mongodb/log

chown -R mongodb:mongodb /rtu/mongodb

# enable service
ln -s /rtu/mongodb/service/mongodb.service /etc/systemd/system/mongodb.service
sudo systemctl enable mongodb.service

# logrotate
mkdir -p /etc/logrotate.d
cat > /etc/logrotate.d/mongodb.conf <<EOF
/rtu/mongodb/log/mongod.log {
  daily
  minsize 10M
  rotate 100
  maxage 30
  missingok
  compress
  delaycompress
  notifempty
  create 640 mongodb mongodb
  sharedscripts
  postrotate
    /bin/kill -SIGUSR1 `cat /run/mongodb/mongod.pid 2>/dev/null` >/dev/null 2>&1 || true
  endscript
}
EOF
