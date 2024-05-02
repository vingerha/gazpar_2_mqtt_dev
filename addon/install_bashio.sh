#!/bin/bash
echo "installing bashio"
set -e

for files in "/etc/services.d" "/etc/cont-init.d"; do

    # Next directory if does not exists
    if ! ls $files 1>/dev/null 2>&1; then continue; fi

    # Bashio
    if grep -q -rnw "$files/" -e 'bashio' && [ ! -f "/usr/bin/bashio" ]; then
        [ "$VERBOSE" = true ] && echo "install bashio"
        BASHIO_VERSION="0.14.3"
        mkdir -p /tmp/bashio
        curl -f -L -s -S "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" | tar -xzf - --strip 1 -C /tmp/bashio
        mv /tmp/bashio/lib /usr/lib/bashio
        ln -s /usr/lib/bashio/bashio /usr/bin/bashio
        rm -rf /tmp/bashio
    fi
done	