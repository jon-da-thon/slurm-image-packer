#!/bin/bash


set -eo pipefail


2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 


# remove ssh host keys
sudo rm -f /etc/ssh/ssh_host_*
