#!/bin/bash

set -eo pipefail

2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait

export DEBIAN_FRONTEND=noninteractive  # bloop

DELAY_SVCS="slurm"
for svc in ${DELAY_SVCS}; do
  ln -s /dev/null "/etc/systemd/system/${svc}.service"
done

### install general build deps
apt-get update
apt-get install -y build-essential libssl-dev libfreeipmi-dev freeipmi freeipmi-tools fakeroot devscripts equivs

### install slurm
wget https://download.schedmd.com/slurm/slurm-24.05.3.tar.bz2
tar -xaf slurm*.tar.bz2
cd `find  -maxdepth 1 -type d -iname "*slurm*"`
# install debian packaging build deps
yes | mk-build-deps -i debian/control
# install slurm packages
debuild -b -uc -us

for svc in ${DELAY_SVCS}; do
  ln -s /dev/null "/etc/systemd/system/${svc}.service"
done

# remove masking symlinks
for svc in ${DELAY_SVCS}; do
  rm "/etc/systemd/system/${svc}.service"
done
