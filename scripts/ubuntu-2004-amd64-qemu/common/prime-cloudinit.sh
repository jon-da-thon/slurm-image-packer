#!/bin/bash

set -eo pipefail


2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 

# remove the subiquity / debian installer config which masks other datasources 
rm -v /etc/cloud/cloud.cfg.d/99-installer.cfg

# and the one that disables network configuration
rm -v /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg

# prime cloud-init
cloud-init clean -l
cloud-init status
