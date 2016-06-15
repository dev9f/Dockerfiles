#!/bin/bash

# Dockerfile ENV
#APP_HOME="/app"
#WORK="/work"

set -m
#InfluxDB ENV Check
: "${IFDB_HOME:=/app/influxdb}"
: "${IFDB_LOGS_DIR:=/app/influxdb/logs}"
: "${IFDB_DATA_DIR:=/app/influxdb/data}"
: "${IFDB_CONF_FILE:=/app/influxdb/conf/config.toml}"
: "${IFDB_CONF_FILE_REP:=/app/influxdb/conf/config.toml.replace}"


: "${IFDB_HOST_ADDR:=localhost}"
: "${IFDB_API_SVC_PORT:=8036}"
: "${IFDB_API_URL:=http://localhost:8086}"

: "${IFDB_DEFT_PWD:=root}"
: "${IFDB_INIT_DB:=stigma}"
: "${IFDB_INIT_DB_USER_NM:=stigma}"
: "${IFDB_INIT_DB_USER_PWD:=stigma}"


function initialize_database() {
	# Pre create database on the initiation of the container
	echo "+++++ About to create the following database: ${IFDB_INIT_DB}"

  start_bg_influxdb
  arr=$(echo ${IFDB_INIT_DB} | tr ";" "\n")

  echo "+++++ First Configuration Databases"
  echo "IFDB_INIT_DB_USER_NM : ${IFDB_INIT_DB_USER_NM}"
  echo "IFDB_INIT_DB_USER_PWD  : ${IFDB_INIT_DB_USER_PWD}"
  echo "DEFT_INIT_PWD : ${IFDB_DEFT_PWD}"

  for dbnm in $arr
  do
      echo "+++++ Creating database: ${dbnm}"
      curl -s -k -X POST -d "{\"name\":\"${dbnm}\"}" $(echo ${IFDB_API_URL}'/db?u=root&p='${IFDB_DEFT_PWD})
      echo "+++++ Creating database users: ${dbnm}"
      curl -s -k -X POST -d "{\"name\":\"${IFDB_INIT_DB_USER_NM}\",\"password\":\"${IFDB_INIT_DB_USER_PWD}\"}" $(echo ${IFDB_API_URL}'/db/'${dbnm}'/users?u=root&p='${IFDB_DEFT_PWD})
      echo "+++++ Allow admin : ${dbnm}"
      curl -s -k -X POST -d "{\"admin\": true}" $(echo ${IFDB_API_URL}'/db/'${dbnm}'/users/'${IFDB_INIT_DB_USER_NM}'?u=root&p='${IFDB_DEFT_PWD})
  done
  stop_bg_influxdb
}


function start_bg_influxdb() {
	echo "+++++ Starting InfluxDB Background ..."
	exec /usr/bin/influxdb -config=${IFDB_CONF_FILE} &

	#wait for the startup of influxdb
  RET=1
  while [[ RET -ne 0 ]]; do
  	echo "+++++ Waiting for confirmation of InfluxDB service startup ..."
  	sleep 3
  	curl -k ${IFDB_API_URL}/ping 2> /dev/null
  	RET=$?
  done
}


function stop_bg_influxdb() {
  echo "+++++ terminate influxdb Background process ..."

  PID=`pgrep influxdb`
  if [[ "" !=  "$PID" ]]; then
    echo "+++++ killing InfluxDB Process(PID) : $PID"
    kill -9 $PID
  fi
}

# Replace Influxdb configuration
function config_replace() {
	sed -i "s|###IFDB_LOGS_DIR###|${IFDB_LOGS_DIR}|" ${IFDB_CONF_FILE_REP}
	sed -i "s|###IFDB_DATA_DIR###|${IFDB_DATA_DIR}|" ${IFDB_CONF_FILE_REP}
}

# Finds the environment variable  and returns its value if found.
# Otherwise returns the default value if provided.
#
# Arguments:
# $1 env variable name to check
# $2 default value if environemnt variable was not set
function find_env() {
    var=`printenv "$1"`

    # If environment variable exists
    if [ -n "$var" ]; then
        echo $var
    else
        echo $2
    fi
}



##################################################################

## Extract/Init InfluxDB if it does not exists
if [ -e ${IFDB_HOME} ]; then
    echo "+++++ ${IFDB_HOME} already exists ..."
else
    echo "+++++ ${IFDB_HOME} does not exists ..."
    echo "+++++ InfluxDB directory create and copy config files..."

    mkdir -p ${IFDB_HOME}/conf
    cp ${WORK}/conf/config.toml ${IFDB_CONF_FILE}
    ##Test
    cp ${WORK}/conf/config.toml.replace ${IFDB_CONF_FILE_REP}
    config_replace
fi

# exist Data File?
if [ ! -d "$IFDB_HOME/data/db" ]; then
    echo "+++++ Initializing Database..."
    initialize_database
else
    echo "+++++ Database had been created before, skipping ..."
fi


echo "+++++ Starting InfluxDB ..."
exec /usr/bin/influxdb -config=${IFDB_CONF_FILE}
