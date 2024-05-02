#!/bin/sh
set -e

echo "Load environment vars"
set -e

####################
# LOAD CONFIG.YAML #
####################

# Exit if /config is not mounted
if [ ! -d /config ]; then
	echo "Error: /config not mounted"
    exit 0
fi

# Default location
CONFIGSOURCE="/config/gazpar_2_mqtt/config.yaml"
echo "Config source: $CONFIGSOURCE"
mkdir -p -v /config/gazpar_2_mqtt

# Migrate if needed
echo "before migrate 2"
cp -rf /homeassistant/gazpar_2_mqtt/* /config/gazpar_2_mqtt/ 

# Check if config file is there, or create one from template
if [ ! -f "$CONFIGSOURCE" ]; then
    echo "... no config file found, Please create $CONFIGSOURCE "
fi

# Export all yaml entries as env variables

while IFS= read -r line; do
    # Clean output
	echo "Line0: $line"
    line="${line//[\"\']/}"
	echo "Line1: $line"
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
		echo "Line2 / secret: $line"
    fi
    # Data validation
	echo "Line3: $line"
    if [[ "$line" =~ ^.+[=].+$ ]]; then
        # extract keys and values
		echo "Line4: $line"
        KEYS="${line%%=*}"
        VALUE="${line#*=}"
        line="${KEYS}='${VALUE}'"
		echo "Line for export: $line"
        export "$line"
        # export to python
        if command -v "python3" &>/dev/null; then
            [ ! -f /env.py ] && echo "import os" > /env.py
            echo "os.environ['${KEYS}'] = '${VALUE//[\"\']/}'" >> /env.py
            python3 /env.py
        fi
		echo "Line for env: $line"
        # set .env
        if [ -f /.env ]; then echo "$line" >> /.env; fi
        mkdir -p /etc
        echo "$line" >> /etc/environment
        # Export to scripts
		echo "Line export to scripts: $line"
        if cat /etc/services.d/*/*run* &>/dev/null; then sed -i "1a export $line" /etc/services.d/*/*run* 2>/dev/null; fi
        if cat /etc/cont-init.d/*run* &>/dev/null; then sed -i "1a export $line" /etc/cont-init.d/*run* 2>/dev/null; fi
        # For s6
        if [ -d /var/run/s6/container_environment ]; then printf "%s" "${VALUE}" > /var/run/s6/container_environment/"${KEYS}"; fi
        echo "export $line" >> ~/.bashrc
        # Show in log
        echo "Last line: $line"
    else
        echo "$line does not follow the correct structure. Please check your yaml file."
    fi
done <"$CONFIGSOURCE"
echo "End of config_yaml.sh"

########################
# LOAD CONFIG.YAML END #
########################

if [ ! -z "$GAZPAR_2_MQTT_APP" ]; then
    APP="$GAZPAR_2_MQTT_APP"
else
    APP="/app"
fi

echo "Using '$APP' as APP directory"

echo "Copying default app/*.py files to app (except param.py)..."
cp /app_temp/database.py "$APP/database.py"
cp /app_temp/gazpar.py "$APP/gazpar.py"
cp /app_temp/gazpar2mqtt.py "$APP/gazpar2mqtt.py"
cp /app_temp/hass.py "$APP/hass.py"
cp /app_temp/influxdb.py "$APP/influxdb.py"
cp /app_temp/mqtt.py "$APP/mqtt.py"
cp /app_temp/price.py "$APP/price.py"
cp /app_temp/standalone.py "$APP/standalone.py"

if [ ! -f "$APP/param.py" ]; then
    echo "param.py non existing, copying default to /app..."
    cp /app_temp/param.py "$APP/param.py"
fi

exec "$@"