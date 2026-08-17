FROM ghcr.io/mihaiush/build:26.803.15 AS build

# renovate: datasource=deb depName=transmission-daemon registryUrl=https://deb.debian.org/debian?suite=testing&components=main&binaryArch=amd64
ENV TRANSMISSION_VERSION="4.1.3+dfsg-1"

RUN \
    export DEBIAN_FRONTEND=noninteractive &&\
    apt-get -q -y update &&\
    apt-get -q -y dist-upgrade --auto-remove &&\
    apt-get -q -y install transmission-daemon=$TRANSMISSION_VERSION 

RUN \
    ldd_jail build \
        /usr/bin/transmission-daemon /usr/share/transmission

FROM scratch

COPY --from=build /tmp/build/ /

VOLUME /tmp

USER 1

ENTRYPOINT ["/usr/bin/transmission-daemon", "-f", "--log-level=info"]
