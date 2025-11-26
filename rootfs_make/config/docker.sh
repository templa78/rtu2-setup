#!/bin/bash

set -ex

echo 'export DOCKER_HOST=unix:///run/user/$UID/docker.sock' >> ~/.bashrc

docker network create \
  --driver=bridge \
  --subnet=172.19.0.0/16 \
  --gateway=172.19.0.1 \
  rtu-net
