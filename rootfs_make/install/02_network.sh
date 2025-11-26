#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

cp misc/90-only-loopback-ipv6.conf /etc/sysctl.d/

mkdir -p /etc/netplan
rm -rf /etc/netplan/*

cat > /etc/netplan/10-dhcp.yaml <<EOF
network:
  ethernets:
    eth0:
      dhcp4: true
      dhcp4-overrides:
        route-metric: 300
    eth1:
      dhcp4: true
      dhcp4-overrides:
        route-metric: 400
EOF

cat > /etc/netplan/30-iderms.yaml <<EOF
network:
  ethernets:
    eth0:
      dhcp4: true
    eth1:
      dhcp4: true
EOF

cat > /etc/netplan/60-lo.yaml <<EOF
network:
  ethernets:
    lo:
      match:
        name: lo
      set-name: lo
      addresses:
        - 10.224.92.71/32
EOF

cat > /etc/netplan/70-usb_wlan.yaml <<EOF
network:
  ethernets:
    usb_wlan:
      match:
        driver: rndis_host
      set-name: usb_wlan
      optional: true
      dhcp4: true
      dhcp4-overrides:
        route-metric: 200
      dhcp6: no
      accept-ra: no
      link-local: [ipv4]
EOF

cat > /etc/netplan/80-usb_lan.yaml <<EOF
network:
  ethernets:
    usb_lan:
      match:
        driver: r8152
      set-name: usb_lan
      optional: true
      dhcp4: true
      dhcp4-overrides:
        route-metric: 100
      dhcp6: no
      accept-ra: no
      link-local: [ipv4]
EOF

cat > /etc/netplan/90-restriction.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp6: no
      accept-ra: no
      link-local: [ipv4]
    eth1:
      dhcp6: no
      accept-ra: no
      link-local: [ipv4]
EOF

