#!/bin/bash

set -eo pipefail

2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 

apt-get clean
apt-get autoclean
rm -rf /var/lib/apt/lists/*
