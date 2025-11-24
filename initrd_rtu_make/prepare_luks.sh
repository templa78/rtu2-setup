#!/bin/bash

rm -rf ./initrds

mkdir -p ./initrds/ng3k
mkdir -p ./initrds/nohs
mkdir -p ./initrds/nobr
mkdir -p ./initrds/dist
cp -a /home/iderms/Work/g3k/g3k_luks/data/g3k_luks_ng3k ./initrds/ng3k/g3k_luks
cp -a /home/iderms/Work/g3k/g3k_luks/data/g3k_luks_nohs ./initrds/nohs/g3k_luks
cp -a /home/iderms/Work/g3k/g3k_luks/data/g3k_luks_nobr ./initrds/nobr/g3k_luks
cp -a /home/iderms/Work/g3k/g3k_luks/data/g3k_luks_dist ./initrds/dist/g3k_luks
chown root:root ./initrds/ng3k/g3k_luks
chown root:root ./initrds/nohs/g3k_luks
chown root:root ./initrds/nobr/g3k_luks
chown root:root ./initrds/dist/g3k_luks
