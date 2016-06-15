#!/bin/bash


export APP_HOME="/app"
export WORK="/work"
export NAGIOS_HOME="/app/nagios"
export GRAPHIOS_HOME="/app/nagios/graphios"
export GRAPHIOS_LOGS="/app/nagios/graphios/logs"
export GRAPHIOS_SPOOL="/var/spool/nagios/graphios"
export INFLUXDB_SERVER="influxdb"
export INFLUXDB_DB="stigma"
export INFLUXDB_USER="stigma"
export INFLUXDB_PASS="stigma"


if [ -e ${NAGIOS_HOME} ]
then
    echo "${NAGIOS_HOME} already exists."
else
    echo "${NAGIOS_HOME} does not exists."
    tar xvfz ${WORK}/nagios.tar.gz
fi


 ## Graphios Start
nohup  ${GRAPHIOS_HOME}/graphios.py -v --backend=influxdb --config_file=${GRAPHIOS_HOME}/graphios.cfg &

# Nagios Start
${NAGIOS_HOME}/bin/nagios -d ${NAGIOS_HOME}/etc/nagios.cfg

#httpd start
apachectl -f /etc/httpd/conf/httpd.conf -DFOREGROUND
