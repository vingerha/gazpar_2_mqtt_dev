#!/bin/bash
echo "installing bashio"
set -e
BASHIO_VERSION="0.14.3"
mkdir -p /tmp/bashio
curl -f -L -s -S "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" | tar -xzf - --strip 1 -C /tmp/bashio
mv /tmp/bashio/lib /usr/lib/bashio
ln -s /usr/lib/bashio/bashio /usr/bin/bashio
rm -rf /tmp/bashio
