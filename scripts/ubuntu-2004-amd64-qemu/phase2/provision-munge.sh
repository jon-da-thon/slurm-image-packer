#!/bin/bash

set -eo pipefail

2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 

export DEBIAN_FRONTEND=noninteractive  # bloop

DELAY_SVCS="munge"
for svc in ${DELAY_SVCS}; do
  ln -s /dev/null "/etc/systemd/system/${svc}.service"
done

# install build deps
apt-get update
apt-get install -y build-essential libssl-dev libbz2-dev bzip2 pkg-config zlib1g-dev

gpg --fetch-keys https://github.com/dun.gpg
gpg --fingerprint 0x3B7ECB2B30DE0871
wget https://github.com/dun/munge/releases/download/munge-0.5.16/munge-0.5.16.tar.xz
tar -xvf munge-0.5.16.tar.xz
cd munge-0.5.16/
./configure      --prefix=/usr      --sysconfdir=/etc      --localstatedir=/var      --runstatedir=/run
make
make check || /bin/true
make install
useradd -m munge
mkdir /run/munge
chmod 0755 /run/munge/
chown munge:munge /run/munge/
chown munge:munge -R /var/log/munge/
chown munge:munge -R /etc/munge

# remove masking symlinks
for svc in ${DELAY_SVCS}; do
  rm "/etc/systemd/system/${svc}.service"
done
