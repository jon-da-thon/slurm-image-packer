
#!/usr/bin/bash

set -eo pipefail

export DEBIAN_FRONTEND=noninteractive

cd /tmp


apt-get update;

apt-get install -y --no-install-recommends \
	ca-certificates \
	wget

wget https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb

dpkg -i gitlab-runner_amd64.deb

rm gitlab-runner_amd64.deb
