
#!/bin/env bash

set -eo pipefail

export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH=/usr/local/cargo/bin:$PATH
export RUST_VERSION=nightly

export DEBIAN_FRONTEND=noninteractive

cd /tmp/

apt-get update;

apt-get install -y --no-install-recommends \
	ca-certificates \
	gcc \
	libc6-dev \
	wget

dpkgArch="$(dpkg --print-architecture)"

case "$dpkgArch" in
  amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='6aeece6993e902708983b209d04c0d1dbb14ebb405ddb87def578d41f920f56d' ;;
  *) echo >&2 "unsupported architecture: $dpkgArch"; exit 1 ;;
esac

url="https://static.rust-lang.org/rustup/dist/${rustArch}/rustup-init"
wget "$url"
echo "${rustupSha256} *rustup-init" | sha256sum -c -
chmod +x rustup-init

# install rust with rustup
./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}

# remove rustup installer
rm rustup-init


chmod -R a+w $RUSTUP_HOME $CARGO_HOME

# output versions i guess
rustup --version
cargo --version
rustc --version

# clean up packages 
apt-get remove -y --auto-remove

# remove apt metadata
rm -rf /var/lib/apt/lists/*
