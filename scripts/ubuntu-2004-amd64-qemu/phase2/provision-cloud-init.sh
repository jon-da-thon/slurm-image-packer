#!/bin/bash

set -eo pipefail

2>&1 echo waiting for service start
timeout -k 20 10 systemctl is-system-running --wait 

# pare down datasources so it doesn't spend 120s x 2 timing out on network ones
cat <<\EOF > /etc/cloud/cloud.cfg.d/99_ibm_ds.cfg
datasource_list: [ ConfigDrive, NoCloud, None ]
datasource:
  ConfigDrive:
    dsmode: local
EOF
