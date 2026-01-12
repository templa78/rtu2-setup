#!/bin/bash

PWD=`pwd`
TARGET_DIR=/work/images/rootfs
cd ${TARGET_DIR}

rm -rf dev/* 
rm -rf "lost+found"
rm -rf media/*
rm -rf mnt/*
rm -rf proc/*
rm -rf run/*
rm -rf sys/*
rm -rf tmp/*
rm -rf var/cache/*
rm -rf var/crash/*
rm -rf var/log/*
rm -rf var/tmp/*
rm -rf var/lib/dhcp
rm -rf var/lib/systemd/random-seed

cd ${PWD}
