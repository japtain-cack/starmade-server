# Build remco from specific commit
##################################
FROM golang

ENV REMCO_VERSION v0.12.0

# remco (lightweight configuration management tool) https://github.com/HeavyHorst/remco
RUN go get github.com/HeavyHorst/remco/cmd/remco
RUN cd $GOPATH/src/github.com/HeavyHorst/remco && \
    git checkout ${REMCO_VERSION}
RUN go install github.com/HeavyHorst/remco/cmd/remco

# Build base container
######################
FROM ubuntu:bionic
LABEL author="Nathan Snow"
LABEL description="Starmade server with remco and auto updates"
USER root

ENV DEBIAN_FRONTEND noninteractive
ENV TINI_VERSION v0.19.0
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV STARMADE_HOME /home/starmade

RUN set -eux pipefail && \
  # Update and install packages
  sed -i -e 's#http://\(archive\|security\)#mirror://mirrors#' -e 's#/ubuntu/#/mirrors.txt#' /etc/apt/sources.list && \
  apt-get -y update && apt-get -y install \
    curl \
    gnupg2 \
    sudo \
    openjdk-8-jdk-headless \
    wget \
    git

# Setup starmade user
RUN adduser --shell /bin/bash --home ${STARMADE_HOME} --gecos "" --disabled-password starmade && \
  passwd -d starmade && \
  addgroup starmade sudo

# Add Tini (A tiny but valid init for containers) https://github.com/krallin/tini
RUN wget -O /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
  wget -O /tini.asc https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc && \
  gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && \
  gpg --batch --verify /tini.asc /tini && \
  chmod +x /tini

COPY --from=0 /go/bin/remco /usr/local/bin/remco
COPY --chown=starmade:root remco /etc/remco
RUN chmod -R 0775 etc/remco

USER starmade
WORKDIR ${STARMADE_HOME}

VOLUME ["${STARMADE_HOME}/server"]

COPY --chown=starmade:starmade files/entrypoint.sh ./
RUN chmod ug+x entrypoint.sh

ENTRYPOINT ["/tini", "--", "./entrypoint.sh"]

