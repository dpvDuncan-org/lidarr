# syntax=docker/dockerfile:1
ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}alpine

ARG lidarr_url
ARG LIDARR_RELEASE

ENV PUID=0
ENV PGID=0
ENV LIDARR_RELEASE=${LIDARR_RELEASE}

COPY scripts/start.sh /

RUN apk -U --no-cache upgrade
RUN apk add --no-cache chromaprint --repository http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk add --no-cache libmediainfo icu-libs libintl sqlite-libs ca-certificates curl
RUN mkdir -p /opt/lidarr /config
RUN curl -o - -L "${lidarr_url}" | tar xz -C /opt/lidarr --strip-components=1
RUN apk del curl
RUN chmod -R 777 /opt/lidarr /start.sh

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# ports and volumes
EXPOSE 8686
VOLUME /config

CMD ["/start.sh"]