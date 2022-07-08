# Build remco from specific commit
##################################
FROM golang AS remco

ARG REMCO_VERSION=v0.12.3

# remco (lightweight configuration management tool) https://github.com/HeavyHorst/remco
RUN go install github.com/HeavyHorst/remco/cmd/remco@$REMCO_VERSION


# Build base container
######################
FROM ubuntu:bionic AS ubuntu
LABEL author="Nathan Snow"
LABEL description="Starmade server with remco and auto updates"
USER root

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV STARMADE_HOME /home/starmade
ENV STARMADE_UID=1000
ENV STARMADE_GUID=1000

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
RUN groupadd -g $STARMADE_GUID starmade && \
    useradd -s /bin/bash -d ${STARMADE_HOME} -m -u $STARMADE_UID -g starmade starmade && \
    passwd -d starmade && \
    echo "starmade ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/starmade

COPY --from=remco /go/bin/remco /usr/local/bin/remco
COPY --chown=starmade:root remco /etc/remco
RUN chmod -R 0775 etc/remco

USER starmade
WORKDIR ${STARMADE_HOME}

VOLUME ["${STARMADE_HOME}/server"]

COPY --chown=starmade:starmade files/entrypoint.sh ./
RUN chmod ug+x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

