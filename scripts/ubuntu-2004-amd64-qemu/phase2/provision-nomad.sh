#!/bin/bash

set -eo pipefail


2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 


export DEBIAN_FRONTEND=noninteractive  # bloop

# install orthogonal pub key
mkdir -p ~ubuntu/.ssh /root/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQgVVKXxEMxVTixVLLcHJCu4EeoPFA8ZsBP3b0buAy0" | tee /root/.ssh/authorized_keys > ~ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu ~ubuntu/.ssh
chmod 600 /root/.ssh/authorized_keys ~ubuntu/.ssh/authorized_keys

# install nspawn
apt-get update
apt-get install -y systemd-container debootstrap
DELAY_SVCS="docker nomad consul vault ntp"

for svc in ${DELAY_SVCS}; do
  ln -s /dev/null "/etc/systemd/system/${svc}.service"
done

# install docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get install -y docker-ce
usermod -aG docker ubuntu


# install nomad, consul, vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get install -y nomad consul vault

# install netdata
apt-get install -y netdata

# set up netdata consul service
cat <<\EOF > /etc/consul.d/netdata.hcl
service {
  name = "netdata"
  id   = "netdata"
  port = 19999
  tags = ["monitoring"]

  checks = [
    {
      id = "info"
      name = "HTTP API on port 19999"
      http = "http://localhost:19999/api/v1/info"
      method = "GET"
      interval = "5s"
      timeout = "1s"
    }
  ]
}
EOF

systemctl disable nomad
systemctl disable consul
systemctl disable vault
systemctl disable ntp

# install other deps
apt-get install -y vim dstat iperf3 pigz ntp jq pv

# remove masking symlinks
for svc in ${DELAY_SVCS}; do
  rm "/etc/systemd/system/${svc}.service"
done
