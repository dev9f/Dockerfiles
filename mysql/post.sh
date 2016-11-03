#!/bin/bash

set -m
: "${MYSQL_HOME:=/app/mysql}"
: "${MYSQL_LOGS:=/app/mysql/logs}"
: "${MYSQL_CONF:=/app/mysql/conf}"
: "${MYSQL_DATADIR:=/app/mysql/mysql}"
: "${MYSQL_LANG:=/usr/share/mysql}"
: "${MYSQL_ROOT_PASSWORD:=password}"
: "${MYSQL_DATABASE:=stigma}"

function makedir() {
       mkdir -p ${MYSQL_LOGS}
       mkdir -p ${MYSQL_CONF}
}

function initialize_database() {
       mysql_install_db --defaults-file=${MYSQL_CONF}/my.cnf
       chown -R mysql:mysql ${MYSQL_DATADIR}
}

function set_root_password() {
       mysqladmin -u root password ${MYSQL_ROOT_PASSWORD}
}

function create_database() {
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "create database ${MYSQL_DATABASE}"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES"
}

function bg_stop() {
       echo 'Shutdown local mysql db ...'
       kill $(pgrep mysqld)
       sleep 3
}

if [ -e ${MYSQL_HOME} ]; then
        echo "${MYSQL_HOME} already exists ..."
else
        echo "${MYSQL_HOME} does not exists ..."
        makedir
        cp ${WORK}/my.cnf ${MYSQL_CONF}/my.cnf
fi

if [ ! -d "${MYSQL_DATADIR}" ]; then
        echo "Initializing Database..."
        initialize_database
else
        echo "${MYSQL_DATADIR} already initialized. Just start..."
fi

if [ ! -d ${MYSQL_DATADIR}/${MYSQL_DATABASE} ]; then
        # Start app in the background
        /usr/bin/mysqld_safe --defaults-file=${MYSQL_CONF}/my.cnf --datadir=${MYSQL_DATADIR} --basedir=${MYSQL_HOME} --language=${MYSQL_LANG}/english &
        sleep 3

        echo "Set root password ..."
        set_root_password

        echo "Create ${MYSQL_DATABASE} Database ..."
        create_database

        bg_stop
else
        echo "${MYSQL_DATABASE} Database already exists ..."
fi

# Start app in the foreground
/usr/bin/mysqld_safe --defaults-file=${MYSQL_CONF}/my.cnf --datadir=${MYSQL_DATADIR} --basedir=${MYSQL_HOME} --language=${MYSQL_LANG}/english
