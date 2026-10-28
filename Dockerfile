FROM ghcr.io/mihaiush/build:26.1027.44 AS build

# renovate-regex: datasource=deb packageName=transmission-daemon registryUrl=https://deb.debian.org/debian?suite=testing&components=main&binaryArch=amd64
ENV TRANSMISSION_VERSION="4.1.3+dfsg-1"

# renovate-regex: datasource=github-releases packageName=6c65726f79/Transmissionic
ENV WEB_VERSION="v1.8.0"

RUN \
    export DEBIAN_FRONTEND=noninteractive &&\
    apt-get -q -y update &&\
    apt-get -q -y dist-upgrade --auto-remove &&\
    apt-get -q -y install \
        transmission-daemon=${TRANSMISSION_VERSION} \
        unzip \
        curl

RUN \
    ldd_jail build \
        /usr/bin/transmission-daemon \
        /usr/share/transmission

RUN \
    curl -Ls "https://github.com/6c65726f79/Transmissionic/releases/download/${WEB_VERSION}/Transmissionic-webui-${WEB_VERSION}.zip" >/tmp/transmissionic.zip &&\
    mkdir -p /usr/share/transmissionic &&\
    cd /usr/share/transmissionic &&\
    unzip /tmp/transmissionic.zip &&\
    cp -r /usr/share/transmissionic /tmp/build/usr/share/

FROM scratch

COPY --from=build /tmp/build/ /

VOLUME /tmp

USER 1

ENV TRANSMISSION_HOME="/var/lib/transmission-daemon"
ENV TRANSMISSION_WEB_HOME="/usr/share/transmissionic/web"
ENTRYPOINT ["/usr/bin/transmission-daemon", "-f", "--log-level=info"]
