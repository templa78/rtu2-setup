#!/bin/bash

set -ex

## chroot 환경 내에서 실행되어야 한다
# /dev, /proc 등이 이미 마운트되어 있어야 한다.

# 밖으로 나가는 ping은 허용
setcap cap_net_raw+ep /usr/bin/ping

cat > /etc/sysctl.d/90-disable-ipv6.conf <<EOF
# Ignore ping
net.ipv4.icmp_echo_ignore_all=0

# Disable IPv6 on all non-loopback interfaces; keep IPv6 only on lo (::1)
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1

# Also ignore router advertisements (extra safety)
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.accept_ra=0
EOF

mkdir -p /etc/netplan
rm -rf /etc/netplan/*

cat > /etc/netplan/10-dhcp.yaml <<EOF
network:
  ethernets:
    eth0:
      dhcp4: true
      dhcp4-overrides:
        route-metric: 200
    eth1:
      dhcp4: true
      dhcp4-overrides:
        route-metric: 300
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

USE_LTE_MODEM=0
if [[ ${USE_LTE_MODEM} -eq 1 ]]; then
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
fi

cat > /etc/netplan/80-usb_lan.yaml <<EOF
network:
  ethernets:
    usb0:
      dhcp4: no
      addresses: [10.176.72.211/28]
      routes:
        - to: default
          via: 10.176.72.209
          metric: 500
      nameservers:
        addresses: [168.126.63.1, 8.8.8.8]
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
    usb0:
      dhcp6: no
      accept-ra: no
      link-local: [ipv4]
EOF

