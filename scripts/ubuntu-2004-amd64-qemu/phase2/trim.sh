#!/bin/bash

set -eo pipefail


2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 


export DEBIAN_FRONTEND=noninteractive  # bloop


# remove snaps
systemctl stop snapd
apt-get remove --purge --assume-yes snapd gnome-software-plugin-snap
rm -vrf ~/snap/ /home/*/snap/ /var/cache/snapd/ 
