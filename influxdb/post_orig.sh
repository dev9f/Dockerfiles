#!/bin/bash

# Dockerfile ENV
#APP_HOME="/app"
#APP_INFLUXDB_HOME="/app/influxdb"
#WORK="/work"
#WORK_CONF="/work/conf"

set -m
CONFIG_FILE="/app/influxdb/conf/config.toml"
API_URL="http://localhost:8086"

if [ -z "${PRE_CREATE_DB}" ]; then
   PRE_CREATE_DB="db1"
fi
if [ -z "${INFLUXDB_INIT_PWD}" ]; then
   INFLUXDB_INIT_PWD="password"
fi
if [ -z "${DB_USER_NAME}" ]; then
   DB_USER_NAME="user"
fi
if [ -z "${DB_USER_PWD}" ]; then
   DB_USER_PWD="password"
fi

if [ -e ${APP_INFLUXDB_HOME} ]
then
    echo "${APP_INFLUXDB_HOME} already exists."
else
    echo "+++++ ${APP_INFLUXDB_HOME} does not exists +++"
    echo "+++++ InfluxDB Initialize +++"

    mkdir -p ${APP_INFLUXDB_HOME}/conf
    cp ${WORK_CONF}/config.toml ${CONFIG_FILE}

    # Pre create database on the initiation of the container
    if [ -n "${PRE_CREATE_DB}" ]; then
        echo "+++++ About to create the following database: ${PRE_CREATE_DB}"

        if [ -f "${APP_INFLUXDB_HOME}/data/.pre_db_created" ]; then
            echo "+++++ Database had been created before, skipping ..."
        else
            echo "+++++ Starting InfluxDB ..."
            exec /usr/bin/influxdb -config=${CONFIG_FILE} &
            PASS=${INFLUXDB_INIT_PWD:-root}
            arr=$(echo ${PRE_CREATE_DB} | tr ";" "\n")

        #wait for the startup of influxdb
        RET=1
        while [[ RET -ne 0 ]]; do
            echo "+++++ Waiting for confirmation of InfluxDB service startup ..."
            sleep 3
            curl -k ${API_URL}/ping 2> /dev/null
            RET=$?
        done
        echo "+++++ First Configuration Databases"
        echo "DB_USER_NAME : ${DB_USER_NAME}"
        echo "DB_USER_PWD  : ${DB_USER_PWD}"
        echo "INFLUXDB_INIT_PWD : ${INFLUXDB_INIT_PWD}"

        for x in $arr
        do
            echo "+++++ Creating database: ${x}"
            curl -s -k -X POST -d "{\"name\":\"${x}\"}" $(echo ${API_URL}'/db?u=root&p='${PASS})
            echo "+++++ Creating database users: ${x}"
            curl -s -k -X POST -d "{\"name\":\"${DB_USER_NAME}\",\"password\":\"${DB_USER_PWD}\"}" $(echo ${API_URL}'/db/'${x}'/users?u=root&p='${PASS})
            echo "+++++ Allow admin : ${x}"
            curl -s -k -X POST -d "{\"admin\": true}" $(echo ${API_URL}'/db/'${x}'/users/'${DB_USER_NAME}'?u=root&p='${PASS})
        done
        echo "+++++ Finish"
        fg
        exit 0
	fi
    fi
fi

# Start supervisord
echo "Running the run_supervisor!"
echo "Running the InfluxDB"
supervisord -n -c ${WORK_CONF}/supervisord.conf
