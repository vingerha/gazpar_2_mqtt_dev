ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:7.3.3
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

COPY ./app /app
COPY ./app /app_temp

RUN apt-get update && \ 
	apt-get install -y curl unzip xvfb libxi6 libgconf-2-4  && \ 
    apt-get update && \
    apt-get install -y chromium -y  && \
    apt-get update && \	
	apt-get install python3 -y && \
	apt-get update && \	
    apt-get install python3-pip -y && \
    rm -rf /var/lib/apt/lists/* 
	    
RUN mkdir -p /data

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TZ=Europe/Paris

# Install python requirements
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r /app/requirement.txt

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["python3", "app/gazpar2mqtt.py"]