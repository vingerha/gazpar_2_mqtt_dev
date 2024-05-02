FROM vingerha/gazpar_2_mqtt
# make sure to run bash all the time
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

##################
#  Install apps  #
##################

COPY ./app /app
COPY ./app /app_temp
COPY rootfs/ /

# Uses /bin for compatibility purposes
RUN if [ ! -f /bin/sh ] && [ -f /usr/bin/sh ]; then ln -s /usr/bin/sh /bin/sh; fi && \
    if [ ! -f /bin/bash ] && [ -f /usr/bin/bash ]; then ln -s /usr/bin/bash /bin/bash; fi
	
RUN \
    set -x \
	&& mkdir -p /tmp/bashio \
	&& curl -f -L -s -S "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" | tar -xzf - --strip 1 -C /tmp/bashio \
	&& mv /tmp/bashio/lib /usr/lib/bashio \
	&& ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
	&& rm -rf /tmp/bashio \
	&& echo "Bashio install"
	
################
# 4 Entrypoint #
################
VOLUME [ "/data" ]
VOLUME [ "/app" ]
COPY entrypoint.sh /usr/local/bin/
#COPY config_yaml.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/config_yaml.sh
COPY config_yaml.sh /app/config_yaml.sh
RUN chmod a+x /app/config_yaml.sh

RUN chmod +x /usr/local/bin/entrypoint.sh
CMD ["./config_yaml.sh"]
ENTRYPOINT ["entrypoint.sh"]
CMD ["entrypoint.sh"]

CMD ["python3", "app/gazpar2mqtt.py"]

############
# 5 Labels #
############

LABEL \
  io.hass.version="0.2.0" \
  io.hass.type="addon" \
  io.hass.arch="armv7|amd64|arm64"


