#!/bin/bash

set -eo pipefail

2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 

# set up vagrant user
adduser --disabled-password --gecos "" vagrant

mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# vagrant expects passwordless-sudo https://www.vagrantup.com/docs/boxes/base#password-less-sudo
cat <<\EOF > /etc/sudoers.d/vagrant
vagrant ALL=(ALL) NOPASSWD: ALL
EOF

# clean up installer netplan config
rm /etc/netplan/*.yaml

# install a netplan config suitable for vagrant-libvirt
cat <<\EOF > /etc/netplan/00-vagrant.yaml
network:
  ethernets:
    vnic:
      dhcp4: true
      match:
        name: en*
EOF

# force the cloud-init ibmcloud DS to work without xen
cat <<\EOF | patch -p1 /usr/lib/python3/dist-packages/cloudinit/sources/DataSourceIBMCloud.py
diff -ru a/DataSourceIBMCloud.py b/DataSourceIBMCloud.py
--- a/DataSourceIBMCloud.py	2022-02-08 22:08:16.258329899 +0000
+++ b/DataSourceIBMCloud.py	2022-02-08 22:08:59.438413433 +0000
@@ -196,7 +196,7 @@
 
 
 def _is_xen():
-    return os.path.exists("/proc/xen")
+    return True
 
 
 def _is_ibm_provisioning(
EOF
