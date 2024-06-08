# Build remco from specific commit
##################################
FROM golang AS remco

# remco (lightweight configuration management tool) https://github.com/HeavyHorst/remco
RUN go install github.com/HeavyHorst/remco/cmd/remco@latest


# Build base container
######################
FROM ubuntu:oracular AS base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV STARMADE_HOME /home/starmade
ENV STARMADE_UID=10000
ENV STARMADE_GUID=10000

USER root

# Update and install packages
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install \
    curl \
    gnupg2 \
    sudo \
    openjdk-8-jdk-headless \
    wget

# Setup starmade user
RUN groupadd -g $STARMADE_GUID starmade && \
    useradd -l -s /bin/bash -d ${STARMADE_HOME} -m -u $STARMADE_UID -g starmade starmade && \
    passwd -d starmade

# install REMCO
COPY --from=remco /go/bin/remco /usr/local/bin/remco
COPY --chown=starmade:root remco /etc/remco
RUN chmod -R 0775 etc/remco

# Build starmade image
######################
FROM base as starmade
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV STARMADE_HOME /home/starmade
ENV STARMADE_UID=10000
ENV STARMADE_GUID=10000

LABEL maintainer=$CI_COMMIT_AUTHOR
LABEL author=nathan.snow@mimir-tech.org
LABEL description="Soulmask dedicated server with SteamCMD automatic updates and remco auto-config"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="registry.gitlab.com/japtain_cack/soulmask-server"
LABEL org.label-schema.description="Soulmask dedicated server with SteamCMD automatic updates and remco auto-config"
LABEL org.label-schema.url=$CI_PROJECT_URL
LABEL org.label-schema.vcs-url=$CI_PROJECT_URL
LABEL org.label-schema.docker.cmd="docker run -it -d -v /mnt/soulmask/world1/:/home/soulmask/server/ -p 7777/udp -p 27015/udp -p 18888/tcp registry.gitlab.com/japtain_cack/soulmask-server"
LABEL org.label-schema.vcs-ref=$CI_COMMIT_SHA
LABEL org.label-schema.version=$CI_COMMIT_TAG
LABEL org.label-schema.build-date=$CI_COMMIT_TIMESTAMP

USER starmade
WORKDIR ${STARMADE_HOME}

VOLUME ["${STARMADE_HOME}/server"]

COPY --chown=starmade:starmade files/entrypoint.sh ./
RUN chmod ug+x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

