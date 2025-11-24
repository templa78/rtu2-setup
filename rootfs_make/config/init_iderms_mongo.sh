#!/bin/bash

set -ex

MONGO_HOST="10.224.92.71"
SCRIPT_PATH="init_iderms_mongo.js"

mongo --host "$MONGO_HOST" "$SCRIPT_PATH"
