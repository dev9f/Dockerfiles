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

function setup_httpd_vhosts() {
    cp ${WORK_CONF}/httpd-vhosts.conf /etc/httpd/conf.d/
    sed -i "s|###STIGMA_HOME###|${STIGMA_HOME}|g" /etc/httpd/conf.d/httpd-vhosts.conf
}

function setup_env() {
    sed -i "s/DB_HOST=/#DB_HOST=/g" ${STIGMA_HOME}/.env
    sed -i "s/DB_DATABASE=/#DB_DATABASE=/g" ${STIGMA_HOME}/.env
    sed -i "s/DB_USERNAME=/#DB_USERNAME=/g" ${STIGMA_HOME}/.env
    sed -i "s/DB_PASSWORD=/#DB_PASSWORD=/g" ${STIGMA_HOME}/.env

#    cat <<'EOF' >> ${STIGMA_HOME}/.env
#    DB_HOST=###MYSQL_HOST###
#    DB_DATABASE=###MYSQL_DATABASE###
#    DB_USERNAME=###MYSQL_USERNAME###
#    DB_PASSWORD=###MYSQL_ROOT_PASSWORD###
#    EOF
#
#    sed -i "s|###MYSQL_HOST###|${MYSQL_HOST}|g" ${STIGMA_HOME}/.env
#    sed -i "s|###MYSQL_DATABASE###|${MYSQL_DATABASE}|g" ${STIGMA_HOME}/.env
#    sed -i "s|###MYSQL_USERNAME###|${MYSQL_USERNAME}|g" ${STIGMA_HOME}/.env
#    sed -i "s|###MYSQL_ROOT_PASSWORD###|${MYSQL_ROOT_PASSWORD}|g" ${STIGMA_HOME}/.env

    echo "NAGIOS_HOST="${STIGMA_NAGIOS_HOST} >> ${STIGMA_HOME}/.env
    echo "IFDB_HOST="${STIGMA_IFDB_HOST} >> ${STIGMA_HOME}/.env
    echo "GRAFANA_HOST="${STIGMA_GRAFANA_HOST} >> ${STIGMA_HOME}/.env
    echo "DB_HOST="${MYSQL_HOST} >> ${STIGMA_HOME}/.env
    echo "DB_DATABASE="${MYSQL_DATABASE} >> ${STIGMA_HOME}/.env
    echo "DB_USERNAME="${MYSQL_USERNAME} >> ${STIGMA_HOME}/.env
    echo "DB_PASSWORD="${MYSQL_ROOT_PASSWORD} >> ${STIGMA_HOME}/.env
}

if [ -e ${STIGMA_HOME} ]
then
    echo "+++++ ${STIGMA_HOME} already exists."
else
    echo "+++++ ${STIGMA_HOME} does not exists ..."
    echo "+++++ Laravel App Directory create and copy config files..."
    setup_httpd_vhosts

    ## Laravel Setting
    cd ${APP_HOME} && git clone https://github.com/stigma2/stigma2-dev.git ${STIGMA_HOME}
    cd ${STIGMA_HOME} && chmod -R 777 storage && composer install
    cp ${STIGMA_HOME}/.env.example ${STIGMA_HOME}/.env
    cd ${STIGMA_HOME} && php artisan key:generate
    setup_env
    cd ${STIGMA_HOME} && php artisan migrate && php artisan db:seed
    chmod 777 ${STIGMA_HOME}/config # && chown nagios:apache ${STIGMA_HOME}/config
fi


# Application Start - Httpd
/usr/sbin/httpd -D FOREGROUND
