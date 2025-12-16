#!/bin/bash

set -ex

#MONGO_HOST="10.224.92.71"
#SCRIPT_PATH="mongo.js"
#mongo --host "$MONGO_HOST" "$SCRIPT_PATH"

echo 'export DOCKER_HOST=unix:///run/user/$UID/docker.sock' >> ~/.bashrc
dockerd-rootless-setuptool.sh install

