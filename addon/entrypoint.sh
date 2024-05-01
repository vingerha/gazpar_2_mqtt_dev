# Pinched a bit from Alexbelgium (thanks)
#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# shellcheck disable=SC2155,SC1087,SC2163,SC2116,SC2086
set -e



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

exec "python3 app/gazpar2mqtt.py"