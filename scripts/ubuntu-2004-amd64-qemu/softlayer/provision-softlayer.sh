#!/bin/bash


set -eo pipefail


2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 


# install citrix/xen guest tools 
cd /tmp/ ;
wget "http://${PACKER_HTTP_ADDR}/ubuntu-2004-amd64-qemu/CitrixHypervisor-LinuxGuestTools-7.20.0-1.tar.gz" ;
tar -xvf /tmp/CitrixHypervisor-LinuxGuestTools-*.tar.gz ;
pushd /tmp/LinuxGuestTools*/ ;
./install.sh -n ;
popd ;

# clean up the weak password on ubuntu user
passwd --delete ubuntu
passwd -S ubuntu

# swap
echo "LABEL=SWAP-xvdb1	none	swap	sw,comment=cloudconfig,auto,nofail	0	2" >> /etc/fstab

# networklayer mirrors
cat <<\EOF > /etc/cloud/cloud.cfg.d/99-networklayer_common.cfg
# CLOUD_IMG: This file was created/modified by the Cloud Image build process
# Configuration for networklayer and then stolen by jonathan

# Default user for networklayer is root
ssh_pwauth: True
disable_root: False
manage_etc_hosts: localhost

# This overrides the default block mapping for swap, by explicitly
# defining the swap to be on a device with label SWAP-xvdb1.
# The first line is needed to remove the default mapping first
mounts:
- [ swap ]
- [ LABEL=SWAP-xvdb1, none, swap, sw ]

system_info:
   package_mirrors:
     - arches: [i386, amd64]
       failsafe:
         primary: http://archive.ubuntu.com/ubuntu
         security: http://security.ubuntu.com/ubuntu
       search:
         primary:
           - http://mirrors.service.networklayer.com/ubuntu
         security:
           - http://mirrors.service.networklayer.com/ubuntu
     - arches: [ppc64el, armhf, armel, default]
       failsafe:
         primary: http://ports.ubuntu.com/ubuntu-ports
         security: http://ports.ubuntu.com/ubuntu-ports
EOF

# clean up netplan configuration from ubuntu installer
rm /etc/netplan/00-installer-config.yaml
