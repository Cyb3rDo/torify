FROM ubuntu:latest
MAINTAINER Ruggero <infiniteproject@gmail.com>

ENV DOCKER_HOST unix:///tmp/docker.sock
ENV DOCKER_GEN_VERSION 0.7.3
ENV DEBIAN_FRONTEND noninteractive

VOLUME /var/lib/tor
WORKDIR /app

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        tor \
        wget \
        ca-certificates

COPY Procfile /app/Procfile
ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod +x /usr/local/bin/forego

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
    tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
    rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz
	
RUN apt-get clean && \
    rm -fr /var/lib/apt/lists/* \
           /tmp/* \
	   /var/tmp/*

ADD torrc.tmpl /app/torrc.tmpl
	
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["forego", "start", "-r"]
