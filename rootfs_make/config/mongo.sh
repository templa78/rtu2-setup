#!/bin/bash

set -ex

MONGO_HOST="10.224.92.71"
SCRIPT_PATH="mongo.js"

mongo --host "$MONGO_HOST" "$SCRIPT_PATH"
