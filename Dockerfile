ARG BUILD_FROM=ghcr.io/hassio-addons/base:12.2.2
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

COPY ./app /app
COPY ./app /app_temp

RUN apk add --no-cache \
        py-urllib3 \
        py3-colorama \
        xvfb \
        py3-pip \
        xorg-server-xephyr \
        chromium-chromedriver \
        chromium \
        py3-openssl \
        py3-pysocks \
        py3-wsproto \
        py3-requests \
        py3-sniffio \
        py3-async_generator \
        py3-sortedcontainers \
        py3-attrs \
        py3-outcome \
        py3-trio \
        py3-paho-mqtt	
	    
RUN mkdir -p /data

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TZ=Europe/Paris

# Install python requirements
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /app/requirement.txt

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["python3", "app/gazpar2mqtt.py"]