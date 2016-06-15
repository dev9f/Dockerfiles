#!/bin/bash


# Nagios & Graphios ENV Check
set -m
: "${APP_HOME:=/app}"
: "${WORK:=/work}"
: "${NAGIOS_HOME:=/app/nagios}"
: "${GRAPHIOS_HOME:=/app/nagios/graphios}"
: "${GRAPHIOS_LOGS:=/app/nagios/graphios/logs}"
: "${GRAPHIOS_SPOOL:=/var/spool/nagios/graphios}"
: "${GRAPHIOS_USED:=y}"
: "${INFLUXDB_SERVER:=influxdb}"
: "${INFLUXDB_DB:=stigma}"
: "${INFLUXDB_USER:=stigma}"
: "${INFLUXDB_PASS:=stigma}"

# Nagios home directory check

if [ -e ${NAGIOS_HOME} ]
then
    echo "${NAGIOS_HOME} already exists."
else
    echo "${NAGIOS_HOME} does not exists."
    tar xvfz ${WORK}/nagios.tar.gz -C /
fi



 ## Graphios Start
if [ "${GRAPHIOS_USED}" = "y" ]
then
	nohup  ${GRAPHIOS_HOME}/graphios.py -v --backend=influxdb --config_file=${GRAPHIOS_HOME}/graphios.cfg 1> /dev/null 2>&1 & 
fi

# Nagios Start
${NAGIOS_HOME}/bin/nagios -d ${NAGIOS_HOME}/etc/nagios.cfg

#httpd start
apachectl -f /etc/httpd/conf/httpd.conf -DFOREGROUND




