#!/bin/bash

set -m
#InfluxDB ENV Check
: "${IFDB_HOME:=/app/influxdb}"
: "${IFDB_LOGS_DIR:=/app/influxdb/logs}"
: "${IFDB_DATA_DIR:=/app/influxdb/influxdb/data}"
: "${IFDB_CONF_FILE:=/app/influxdb/conf/influxdb.conf}"

: "${IFDB_API_URL:=http://localhost:8086}"

: "${IFDB_INIT_DB:=stigma}"
: "${IFDB_INIT_DB_USER_NM:=stigma}"
: "${IFDB_INIT_DB_USER_PWD:=stigma}"

function initialize_database() {
    # Pre create database on the initiation of the container
    echo "+++++ About to create the following database: ${IFDB_INIT_DB}"

    start_bg_influxdb

    echo "+++++ Creating database users: ${IFDB_INIT_DB_USER_NM}"
    curl -G ${IFDB_API_URL}/query -u root:root --data-urlencode "q=CREATE USER ${IFDB_INIT_DB_USER_NM} WITH PASSWORD '${IFDB_INIT_DB_USER_PWD}' WITH ALL PRIVILEGES"

    echo "+++++ Creating database: ${IFDB_INIT_DB}"
    curl -G ${IFDB_API_URL}/query -u ${IFDB_INIT_DB_USER_NM}:${IFDB_INIT_DB_USER_PWD} --data-urlencode "q=CREATE DATABASE ${IFDB_INIT_DB}"

    echo "+++++ Writing sample data"
    curl -i -XPOST ${IFDB_API_URL}/write?db=${IFDB_INIT_DB} -u ${IFDB_INIT_DB_USER_NM}:${IFDB_INIT_DB_USER_PWD} --data-binary 'initialize_database value=0'

    stop_bg_influxdb
}

function start_bg_influxdb() {
    echo "+++++ Starting InfluxDB Background ..."
    exec /opt/influxdb/influxd -config=${IFDB_CONF_FILE} &

    #wait for the startup of influxdb
    RET=1
    while [[ $RET -ne 0 ]]; do
        echo "+++++ Waiting for confirmation of InfluxDB service startup ..."
        sleep 3
        curl -k ${IFDB_API_URL}/ping 2> /dev/null
        RET=$?
    done
}

function stop_bg_influxdb() {
    echo "+++++ terminate influxdb Background process ..."

    PID=`pgrep influxd`
    if [[ "" !=  "$PID" ]]; then
        echo "+++++ killing InfluxDB Process(PID) : $PID"
        kill -9 $PID
    fi
}

# Replace Influxdb configuration
function config_replace() {
    sed -i "s|###IFDB_HOME###|${IFDB_HOME}|" ${IFDB_CONF_FILE}
    sed -i "s/###IFDB_HOSTNAME###/$HOSTNAME/g" ${IFDB_CONF_FILE}
    sed -i "s/auth-enabled = false/auth-enabled = true/g" ${IFDB_CONF_FILE}
    sed -i "s/INFLUXD_OPTS=/INFLUXD_OPTS=\"-join influxdb:8088\"/g" /etc/init.d/influxdb
}

##################################################################

## Extract/Init InfluxDB if it does not exists
if [ -e ${IFDB_HOME} ]; then
    echo "+++++ ${IFDB_HOME} already exists ..."
else
    echo "+++++ ${IFDB_HOME} does not exists ..."
    echo "+++++ InfluxDB directory create and copy config files..."

    mkdir -p ${IFDB_HOME}/conf
    cp ${WORK}/conf/influxdb.conf ${IFDB_CONF_FILE}
    config_replace
fi

# exist Data File?
if [ ! -d "$IFDB_DATA_DIR/$IFDB_INIT_DB" ]; then
    echo "+++++ Initializing Database..."
    initialize_database
else
    echo "+++++ Database had been created before, skipping ..."
fi

echo "+++++ Starting InfluxDB ..."
exec /opt/influxdb/influxd -config=${IFDB_CONF_FILE}
