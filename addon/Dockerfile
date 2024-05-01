FROM vingerha/gazpar_2_mqtt

##################
#  Install apps  #
##################

COPY ./app /app
COPY ./app /app_temp
COPY rootfs/ /

# Uses /bin for compatibility purposes
RUN if [ ! -f /bin/sh ] && [ -f /usr/bin/sh ]; then ln -s /usr/bin/sh /bin/sh; fi && \
    if [ ! -f /bin/bash ] && [ -f /usr/bin/bash ]; then ln -s /usr/bin/bash /bin/bash; fi
################
# 4 Entrypoint #
################

COPY entrypoint.sh /usr/local/bin/
COPY config_yaml.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/config_yaml.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["entrypoint.sh"]
VOLUME [ "/data" ]
VOLUME [ "/app" ]
CMD ["python3", "app/gazpar2mqtt.py"]

############
# 5 Labels #
############

LABEL \
  io.hass.version="0.2.0" \
  io.hass.type="addon" \
  io.hass.arch="armv7|amd64|arm64"


