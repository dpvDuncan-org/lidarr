# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}alpine

# see hooks/post_checkout
ARG ARCH
COPY .gitignore qemu-${ARCH}-static* /usr/bin/

# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}alpine

# see hooks/post_checkout
ARG ARCH
COPY qemu-${ARCH}-static /usr/bin

RUN apk update && apk upgrade && \
    apk add --no-cache mono chromaprint --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
    apk add --no-cache mediainfo && \
    apk add --no-cache --virtual=.build-dependencies ca-certificates curl jq && \
    mkdir -p /opt/lidarr && \
    LIDARR_RELEASE=$(curl -sX GET "https://api.github.com/repos/lidarr/Lidarr/releases" | \
            jq -r '.[0] | .tag_name') && \
    lidarr_url=$(curl -s https://api.github.com/repos/lidarr/Lidarr/releases/tags/"${LIDARR_RELEASE}" | \
            jq -r '.assets[].browser_download_url' | grep linux) && \
    curl -o - -L "${lidarr_url}" | tar xz -C /opt/lidarr --strip-components=1 && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    chmod 777 /opt/lidarr -R && \
    apk del .build-dependencies

# ports and volumes
EXPOSE 8686
VOLUME /config

CMD ["mono", "/opt/lidarr/Lidarr.exe", "-nobrowser", "-data=/config"]