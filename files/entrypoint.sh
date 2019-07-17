#!/bin/bash

export STARMADE_HOME=/home/starmade

export REMCO_HOME=/etc/remco
export REMCO_RESOURCE_DIR=${REMCO_HOME}/resources.d
export REMCO_TEMPLATE_DIR=${REMCO_HOME}/templates

remco -config ${REMCO_HOME}/config.toml

cd /home/starmade/server && \
  wget -O StarMade-Starter.jar http://files.star-made.org/StarMade-Starter.jar && \
  java -jar ./StarMade-Starter.jar -nogui && \

chown -R starmade:starmade /home/starmade && \
  cd /home/starmade/server/StarMade && \
  chmod ug+x ./StarMade-dedicated-server-linux.sh && \
  ./StarMade-dedicated-server-linux.sh

