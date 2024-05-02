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