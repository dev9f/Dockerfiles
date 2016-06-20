#!/bin/bash

#APP_HOME="/app"
#WORK="/work"

set -m
: "${MYSQL_HOME:=/app/mysql}"
: "${MYSQL_LOGS:=/app/mysql/logs}"
: "${MYSQL_CONF:=/app/mysql/conf}"
: "${MYSQL_DATADIR:=/app/mysql/mysql}"
: "${MYSQL_LANG:=/usr/share/mysql}"
: "${MYSQL_ROOT_PASSWORD:=password}"
: "${MYSQL_DATABASE:=stigma}"

function makedir() {
       mkdir -p ${MYSQL_HOME}/logs
       mkdir -p ${MYSQL_HOME}/conf
}

function initialize_database() {
       # Mysql_install_db & Start mysql_safe in the background
       mysql_install_db --defaults-file=${MYSQL_CONF}/my.cnf
       chown -R mysql:mysql ${MYSQL_DATADIR}
}

function bg_stop() {
       echo 'Shutdown local mysql db ...'
       kill $(pgrep mysqld)
       sleep 3
}

function check_root_password() {

       # MYSQL_ROOT_PASSWORD
#       if [ -z ${MYSQL_ROOT_PASSWORD} ]; then
#               MYSQL_ROOT_PASSWORD=password
#               echo 'root password is ${MYSQL_ROOT_PASSWORD}'
#       fi
       mysqladmin -u root password ${MYSQL_ROOT_PASSWORD}
}

function create_database() {

	#Create database
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "create database ${MYSQL_DATABASE}"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES"
}

if [ -e ${MYSQL_HOME} ]; then
        echo "${MYSQL_HOME} already exists ..."
else
        echo "${MYSQL_HOME} does not exists ..."
        makedir
        cp ${WORK}/my.cnf $MYSQL_CONF/my.cnf
fi

if [ ! -d "${MYSQL_DATADIR}" ]; then
	echo "Initializing Database..."
   	initialize_database
else
   	echo "Do not initialize Database.Just start..."
fi

# Start app in the background
/usr/bin/mysqld_safe --defaults-file=${MYSQL_CONF}/my.cnf --datadir=${MYSQL_DATADIR} --basedir=${MYSQL_HOME} --language=${MYSQL_LANG}/english &
sleep 3
     
check_root_password
      
if [ ! -z ${MYSQL_DATABASE} ]; then
	create_database
else
	echo "No create Database"
fi
	
bg_stop
       
# Start app in the foreground
/usr/bin/mysqld_safe --defaults-file=${MYSQL_CONF}/my.cnf --datadir=${MYSQL_DATADIR} --basedir=${MYSQL_HOME} --language=${MYSQL_LANG}/english

