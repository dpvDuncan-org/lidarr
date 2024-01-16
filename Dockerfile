# syntax=docker/dockerfile:1

FROM alpine AS builder

ARG lidarr_url
ARG TARGETARCH

COPY scripts/start.sh /

RUN apk -U --no-cache upgrade

RUN apk add --no-cache libmediainfo icu-libs libintl sqlite-libs ca-certificates curl
RUN mkdir -p /opt/lidarr /config
RUN case "${TARGETARCH}" in \
        "arm") echo "arm" > /tmp/lidarr_arch;;\
        "arm64") echo "arm64" > /tmp/lidarr_arch;;\
        "amd64") echo "x64" > /tmp/lidarr_arch;;\
        *) echo "none" > /tmp/lidarr_arch;;\
    esac
RUN lidarr_arch=`cat /tmp/lidarr_arch`; curl -o - -L "${lidarr_url}&arch=${lidarr_arch}" | tar xz -C /opt/lidarr --strip-components=1
RUN apk del curl
RUN chmod -R 777 /opt/lidarr /start.sh

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

FROM scratch

ARG LIDARR_RELEASE

ENV PUID=0
ENV PGID=0
ENV LIDARR_RELEASE=${LIDARR_RELEASE}

COPY --from=builder / /
# ports and volumes
EXPOSE 8686
VOLUME /config

CMD ["/start.sh"]
