# Pinched from Alexbelgium (thanks)
#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# shellcheck disable=SC2155,SC1087,SC2163,SC2116,SC2086
set -e

##################
# INITIALIZATION #
##################

# Exit if /config is not mounted
if [ ! -d /config ]; then
	echo "Error: /config not mounted"
    exit 0
fi

# Default location
CONFIGSOURCE="/config/gazpar_2_mqtt/config.yaml"
echo "Config source: $CONFIGSOURCE"

####################
# LOAD CONFIG.YAML #
####################

# Check if config file is there, or create one from template
if [ ! -f "$CONFIGSOURCE" ]; then
    echo "... no config file, creating one from template. Please customize the file in $CONFIGSOURCE before restarting."
    # Create folder
    mkdir -p "/config/gazpar_2_mqtt"
    # Placing template in config
    if [ -f /templates/config.yaml ]; then
        # Use available template
        cp /templates/config.yaml /config/gazpar_2_mqtt
    else
        echo "No template found to copy from, please create a config.yaml"
    fi
fi

# Check if there are lines to read
cp "$CONFIGSOURCE" /tempenv
sed -i '/^#/d' /tempenv
sed -i '/^ /d' /tempenv
sed -i '/^$/d' /tempenv
# Exit if empty
if [ ! -s /tempenv ]; then
    echo "... no env variables found, exiting"
    exit 0
fi
rm /tempenv

# Check if yaml is valid
EXIT_CODE=0
yamllint -d relaxed "$CONFIGSOURCE" &>ERROR || EXIT_CODE=$?
if [ "$EXIT_CODE" != 0 ]; then
    cat ERROR
    echo "... config file has an invalid yaml format. Please check the file in $CONFIGSOURCE. Errors list above."
fi

# Export all yaml entries as env variables
# Helper function
function parse_yaml {
    local prefix=$2 || local prefix=""
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @ | tr @ '\034')
    sed -ne "s|^\($s\):|\1|" \
        -e "s| #.*$||g" \
        -e "s|#.*$||g" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
    awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
    }'
}

# Get list of parameters in a file
parse_yaml "$CONFIGSOURCE" "" >/tmpfile
# Escape dollars
sed -i 's|$.|\$|g' /tmpfile

while IFS= read -r line; do
    # Clean output
    line="${line//[\"\']/}"
    # Check if secret
    if [[ "${line}" == *'!secret '* ]]; then
        echo "secret detected"
        secret=${line#*secret }
        # Check if single match
        secretnum=$(sed -n "/$secret:/=" /config/secrets.yaml)
        [[ $(echo $secretnum) == *' '* ]] && bashio::exit.nok "There are multiple matches for your password name. Please check your secrets.yaml file"
        # Get text
        secret=$(sed -n "/$secret:/p" /config/secrets.yaml)
        secret=${secret#*: }
        line="${line%%=*}='$secret'"
    fi
    # Data validation
    if [[ "$line" =~ ^.+[=].+$ ]]; then
        # extract keys and values
        KEYS="${line%%=*}"
        VALUE="${line#*=}"
        line="${KEYS}='${VALUE}'"
        export "$line"
        # export to python
        if command -v "python3" &>/dev/null; then
            [ ! -f /env.py ] && echo "import os" > /env.py
            echo "os.environ['${KEYS}'] = '${VALUE//[\"\']/}'" >> /env.py
            python3 /env.py
        fi
        # set .env
        if [ -f /.env ]; then echo "$line" >> /.env; fi
        mkdir -p /etc
        echo "$line" >> /etc/environment
        # Export to scripts
        if cat /etc/services.d/*/*run* &>/dev/null; then sed -i "1a export $line" /etc/services.d/*/*run* 2>/dev/null; fi
        if cat /etc/cont-init.d/*run* &>/dev/null; then sed -i "1a export $line" /etc/cont-init.d/*run* 2>/dev/null; fi
        # For s6
        if [ -d /var/run/s6/container_environment ]; then printf "%s" "${VALUE}" > /var/run/s6/container_environment/"${KEYS}"; fi
        echo "export $line" >> ~/.bashrc
        # Show in log
        if ! bashio::config.false "verbose"; then bashio::log.blue "$line"; fi
    else
        echo "$line does not follow the correct structure. Please check your yaml file."
    fi
done <"/tmpfile"