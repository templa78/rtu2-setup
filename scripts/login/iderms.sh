#!/bin/bash

set -ex

echo 'export DOCKER_HOST=unix:///run/user/$UID/docker.sock' >> ~/.bashrc
dockerd-rootless-setuptool.sh install

