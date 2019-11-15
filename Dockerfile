ARG BASE_IMAGE_PREFIX

FROM multiarch/qemu-user-static as qemu

FROM ${BASE_IMAGE_PREFIX}alpine

ARG lidarr_url
ARG LIDARR_RELEASE

ENV PUID=0
ENV PGID=0
ENV LIDARR_RELEASE=${LIDARR_RELEASE}

COPY --from=qemu /usr/bin/qemu-*-static /usr/bin/
COPY scripts/start.sh /

RUN apk -U --no-cache upgrade
RUN apk add --no-cache mono chromaprint --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk add --no-cache mediainfo
RUN apk add --no-cache --virtual=.build-dependencies ca-certificates curl
RUN mkdir -p /opt/lidarr /config
RUN curl -o - -L "${lidarr_url}" | tar xz -C /opt/lidarr --strip-components=1
RUN apk del .build-dependencies
RUN chmod -R 777 /opt/lidarr /start.sh

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /usr/bin/qemu-*-static

# ports and volumes
EXPOSE 8686
VOLUME /config

CMD ["/start.sh"]