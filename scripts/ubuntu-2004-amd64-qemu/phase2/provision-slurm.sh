#!/bin/bash

set -eo pipefail

2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait

export DEBIAN_FRONTEND=noninteractive  # bloop

DELAY_SVCS="slurm"
for svc in ${DELAY_SVCS}; do
  ln -s /dev/null "/etc/systemd/system/${svc}.service"
done

### install munge and slurm
cd /tmp
wget "http://${PACKER_HTTP_ADDR}/ubuntu-2004-amd64-qemu/munge-0.5.16_1.0_amd64.deb" ;
dpkg -i munge-0.5.16_1.0_amd64.deb
wget "http://${PACKER_HTTP_ADDR}/ubuntu-2004-amd64-qemu/slurm-24.05.3_1.0_amd64.deb" ;
dpkg -i slurm-24.05.3_1.0_amd64.deb

### slurm config
sleep 86400

# remove masking symlinks
for svc in ${DELAY_SVCS}; do
  rm "/etc/systemd/system/${svc}.service"
done
