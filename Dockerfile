FROM ghcr.io/mihaiush/build:26.803.15 AS build

# renovate: datasource=deb depName=transmission-daemon registryUrl=https://deb.debian.org/debian?suite=testing&components=main&binaryArch=amd64
ENV TRANSMISSION_VERSION="4.1.3+dfsg-1"

# renovate: datasource=github-releases depName=6c65726f79/Transmissionic
ENV WEB_VERSION="1.8.0"

RUN \
    export DEBIAN_FRONTEND=noninteractive &&\
    apt-get -q -y update &&\
    apt-get -q -y dist-upgrade --auto-remove &&\
    apt-get -q -y install \
        transmission-daemon=$TRANSMISSION_VERSION \
        unzip \
        curl

RUN \
    ldd_jail build \
        /usr/bin/transmission-daemon \
        /usr/share/transmission

RUN \
    curl -Ls https://github.com/6c65726f79/Transmissionic/releases/download/v${WEB_VERSION}/Transmissionic-webui-v${WEB_VERSION}.zip >/tmp/transmissionic.zip &&\
    mkdir -p /usr/share/transmissionic &&\
    cd /usr/share/transmissionic &&\
    unzip /tmp/transmissionic.zip &&\
    cp -r /usr/share/transmissionic /tmp/build/usr/share/

FROM scratch

COPY --from=build /tmp/build/ /

VOLUME /tmp

USER 1

ENTRYPOINT ["/usr/bin/transmission-daemon", "-f", "--log-level=info"]
