#!/bin/bash

#Env
#APP_HOME="/app"
#WORK="/work"


set -m
#Grafana ENV Check

: "${GF_HOME:=/app/grafana}"
: "${GF_CONF_FILE:=/app/grafana/conf/config.ini}"
: "${GF_DATA_DIR:=/app/grafana/data}"
: "${GF_LOGS_DIR:=/app/grafana/logs}"
: "${GF_PLUGINS_DIR:=/app/grafana/plugins}"

### MAIN ###
if [ -e ${GF_HOME} ]; then
    echo "+++++ ${GF_HOME} already exists."
else
    echo "+++++ ${GF_HOME} does not exists."
    mkdir -p ${GF_HOME}/conf
    cp ${WORK}/conf/config.ini ${GF_CONF_FILE}

    #TEST
    cp ${WORK}/conf/config.ini.replace ${GF_CONF_FILE}
fi

echo "+++++ Grafana Config ..."
echo "Home Directory : ${GF_HOME}"
echo "Configuration file path : ${GF_CONF_FILE}"
echo "Data Directory : ${GF_DATA_DIR}"
echo "Logs Directory : ${GF_LOGS_DIR}"
echo "plugins Directory: ${GF_PLUGINS_DIR}"


echo "+++++ Starting Grafana Server!!"
exec /usr/sbin/grafana-server  \
  --homepath=/usr/share/grafana             \
  --config="${GF_CONF_FILE}"                \
  cfg:default.paths.data="${GF_DATA_DIR}"   \
  cfg:default.paths.logs="${GF_LOGS_DIR}"   \
  cfg:default.paths.plugins="${GF_PLUGINS_DIR}"
