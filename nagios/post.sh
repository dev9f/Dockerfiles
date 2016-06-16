#!/bin/bash


# Nagios & Graphios ENV Check
set -m
: "${APP_HOME:=/app}"
: "${WORK:=/work}"
: "${NAGIOS_HOME:=/app/nagios}"
: "${NAGIOS_USER:=nagiosadmin}"
: "${NAGIOS_PASS:=qwe123}"
: "${GRAPHIOS_HOME:=/app/nagios/graphios}"
: "${GRAPHIOS_SPOOL:=/var/spool/nagios/graphios}"
: "${GRAPHIOS_USED:=y}"
: "${PREFIX_LOCALHOST:=stigma}"
: "${INFLUXDB_PORT_8086_TCP_ADDR:=influxdb}"
: "${INFLUXDB_ENV_IFDB_INIT_DB:=stigma}"
: "${INFLUXDB_ENV_IFDB_INIT_DB_USER_NM:=stigma}"
: "${INFLUXDB_ENV_IFDB_INIT_DB_USER_PWD:=stigma}"


function backup_config () {

 cp ${NAGIOS_HOME}/etc/nagios.cfg ${NAGIOS_HOME}/etc/nagios.cfg.org
 cp ${GRAPHIOS_HOME}/graphios.cfg ${GRAPHIOS_HOME}/graphios.cfg.org
}

function setup_graphios () {
 echo "##### setup_graphios #####"

 mkdir -p ${GRAPHIOS_HOME}/logs
 mkdir -p ${GRAPHIOS_SPOOL}
 chown -R nagios:nagcmd ${GRAPHIOS_SPOOL}
 chmod 755 ${GRAPHIOS_SPOOL}

 write_graphios_perf_templ
 write_graphios_command

 cat ${NAGIOS_CONF}/localhost.cfg > ${NAGIOS_HOME}/etc/objects/localhost.cfg
 sed -i "s|###PREFIX_LOCALHOST###|${PREFIX_LOCALHOST}|g" ${NAGIOS_HOME}/etc/objects/localhost.cfg
 sed -i "s|\/usr\/local\/nagios\/var\/graphios.log|${GRAPHIOS_HOME}\/logs\/graphios.log|g" ${GRAPHIOS_HOME}/graphios.cfg
}

function write_graphios_perf_templ() {

 cat ${NAGIOS_CONF}/graphios_commands.txt >> ${NAGIOS_HOME}/etc/nagios.cfg
 sed -i 's/process_performance_data=0/process_performance_data=1/g' ${NAGIOS_HOME}/etc/nagios.cfg
 sed -i "s|###GRAPHIOS_SPOOL###|${GRAPHIOS_SPOOL}|g" ${NAGIOS_HOME}/etc/nagios.cfg
}

function write_graphios_command() {

 echo "## Graphios Command" >> ${NAGIOS_HOME}/etc/nagios.cfg
 echo "cfg_file=${NAGIOS_HOME}/etc/objects/graphios_commands.cfg" >> ${NAGIOS_HOME}/etc/nagios.cfg
 cp ${NAGIOS_CONF}/graphios_commands.cfg ${NAGIOS_HOME}/etc/objects/
 sed -i "s|###GRAPHIOS_SPOOL###|${GRAPHIOS_SPOOL}|g" ${NAGIOS_HOME}/etc/objects/graphios_commands.cfg
}

function modify_graphios_config () {

 sed -i 's/enable_influxdb = False/enable_influxdb = True/g' ${GRAPHIOS_HOME}/graphios.cfg
 echo "## InfluxDB Information of Nagios Status Data" >> ${GRAPHIOS_HOME}/graphios.cfg
 echo "influxdb_servers = $INFLUXDB_PORT_8086_TCP_ADDR:8086" >> ${GRAPHIOS_HOME}/graphios.cfg
 echo "influxdb_db = $INFLUXDB_ENV_IFDB_INIT_DB" >> ${GRAPHIOS_HOME}/graphios.cfg
 echo "influxdb_user = $INFLUXDB_ENV_IFDB_INIT_DB_USER_NM" >> ${GRAPHIOS_HOME}/graphios.cfg
 echo "influxdb_password = $INFLUXDB_ENV_IFDB_INIT_DB_USER_PWD" >> ${GRAPHIOS_HOME}/graphios.cfg

}

# Nagios home directory check

if [ -e ${NAGIOS_HOME} ]
then
    echo "${NAGIOS_HOME} already exists."
else
    echo "${NAGIOS_HOME} does not exists."
    tar xvfz ${WORK}/nagios.tar.gz -C /
fi

#Creating a password for nagiosadmin
if [ -e ${NAGIOS_HOME}/etc/htpasswd.users ]
then
    echo "htpasswd.users already exists."
else
    echo "htpasswd.users does not exists."
    htpasswd -cb ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOS_USER} ${NAGIOS_PASS}
fi


 ## Graphios Start
if [ "${GRAPHIOS_USED}" = "y" ]
then
    backup_config
    setup_graphios
    modify_graphios_config
    nohup  ${GRAPHIOS_HOME}/graphios.py -v --backend=influxdb --config_file=${GRAPHIOS_HOME}/graphios.cfg 1> /dev/null 2>&1 & 
fi

# Nagios Start
${NAGIOS_HOME}/bin/nagios -d ${NAGIOS_HOME}/etc/nagios.cfg

#httpd start
apachectl -f /etc/httpd/conf/httpd.conf -DFOREGROUND




