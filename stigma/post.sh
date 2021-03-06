#!/bin/bash

#STIGMA ENV Check
set -m
: "${STIGMA_HOME:=/app/stigma}"
: "${STIGMA_NAGIOS_HOST:=nagios}"
: "${STIGMA_IFDB_HOST:=influxdb}"
: "${STIGMA_GRAFANA_HOST:=grafana}"
: "${MYSQL_HOST:=mysql}"
: "${MYSQL_DATABASE:=stigma}"
: "${MYSQL_USERNAME:=root}"
: "${MYSQL_ROOT_PASSWORD:=password}"
: "${GLUSTERFS_MASTER:=192.168.1.200}"

function setup_httpd_vhosts() {
    cp ${WORK_CONF}/httpd-vhosts.conf /etc/httpd/conf.d/
    sed -i "s|###STIGMA_HOME###|${STIGMA_HOME}|g" /etc/httpd/conf.d/httpd-vhosts.conf
}

function setup_env() {
    sed -i "s/DB_HOST=/#DB_HOST=/g" ${STIGMA_HOME}/.env
    sed -i "s/DB_DATABASE=/#DB_DATABASE=/g" ${STIGMA_HOME}/.env
    sed -i "s/DB_USERNAME=/#DB_USERNAME=/g" ${STIGMA_HOME}/.env
    sed -i "s/DB_PASSWORD=/#DB_PASSWORD=/g" ${STIGMA_HOME}/.env

    echo "" >> ${STIGMA_HOME}/.env
    echo "NAGIOS_HOST="${STIGMA_NAGIOS_HOST} >> ${STIGMA_HOME}/.env
    echo "IFDB_HOST="${STIGMA_IFDB_HOST} >> ${STIGMA_HOME}/.env
    echo "GRAFANA_HOST="${STIGMA_GRAFANA_HOST} >> ${STIGMA_HOME}/.env
    echo "DB_HOST="${MYSQL_HOST} >> ${STIGMA_HOME}/.env
    echo "DB_DATABASE="${MYSQL_DATABASE} >> ${STIGMA_HOME}/.env
    echo "DB_USERNAME="${MYSQL_USERNAME} >> ${STIGMA_HOME}/.env
    echo "DB_PASSWORD="${MYSQL_ROOT_PASSWORD} >> ${STIGMA_HOME}/.env
}

function setup_gdeploy() {
    echo "+++++ Setup gdeploy ..."
    mkdir -p ${STIGMA_HOME}/gdeploy/conf && chmod 777 ${STIGMA_HOME}/gdeploy/conf

    echo "${GLUSTERFS_MASTER}" >> /etc/ansible/hosts
}

if [ -e ${STIGMA_HOME} ]
then
    echo "+++++ ${STIGMA_HOME} already exists."
else
    echo "+++++ ${STIGMA_HOME} does not exists ..."
    echo "+++++ Laravel App Directory create and copy config files..."
    setup_httpd_vhosts

    ## Laravel Setting
    cp -R ${WORK}/stigma/ ${APP_HOME}/
    cd ${STIGMA_HOME} && chmod -R 777 storage && composer install
    cp ${STIGMA_HOME}/.env.example ${STIGMA_HOME}/.env
    cd ${STIGMA_HOME} && php artisan key:generate
    setup_env
    cd ${STIGMA_HOME} && php artisan migrate && php artisan db:seed
    chmod 777 ${STIGMA_HOME}/config
    cd ${STIGMA_HOME} && npm install --save
    cd ${STIGMA_HOME}/public && ../node_modules/.bin/bower install --save --allow-root
    cd ${STIGMA_HOME} && npm run prod

    setup_gdeploy
fi

# Application Start - Httpd
/usr/sbin/httpd -D FOREGROUND
