#!/bin/bash

export WORK="/work"
export NAGIOS_HOME="/app/nagios"
export NAGIOS_CONF="/work/conf"
export GRAPHIOS_HOME="/app/nagios/graphios"
export GRAPHIOS_LOGS="/app/nagios/graphios/logs"
export GRAPHIOS_SPOOL="/var/spool/nagios/graphios"
export PREFIX_LOCALHOST="ACS"
export INFLUXDB_SERVER="influxdb"
export INFLUXDB_DB="stigma"
export INFLUXDB_USER="stigma"
export INFLUXDB_PASS="stigma"

#Install graphios
cd ${WORK}

git clone https://github.com/shawn-sterling/graphios.git

cd ${WORK}/graphios

mkdir -p ${GRAPHIOS_HOME}/logs

cp graphios*.py ${GRAPHIOS_HOME}
cp graphios.cfg ${GRAPHIOS_HOME}

mkdir -p ${GRAPHIOS_SPOOL}

chown -R nagios:nagcmd ${GRAPHIOS_SPOOL}
chmod 755 ${GRAPHIOS_SPOOL}

cp ${NAGIOS_HOME}/etc/nagios.cfg ${NAGIOS_HOME}/etc/nagios.cfg.org
echo "## Graphios Command" >> ${NAGIOS_HOME}/etc/nagios.cfg
echo "cfg_file=${NAGIOS_HOME}/etc/objects/graphios_commands.cfg" >> ${NAGIOS_HOME}/etc/nagios.cfg
sed -i 's/process_performance_data=0/process_performance_data=1/g' ${NAGIOS_HOME}/etc/nagios.cfg
cat ${NAGIOS_CONF}/graphios_commands.txt >> ${NAGIOS_HOME}/etc/nagios.cfg
sed -i "s|###GRAPHIOS_SPOOL###|${GRAPHIOS_SPOOL}|g" ${NAGIOS_HOME}/etc/nagios.cfg
cp ${NAGIOS_CONF}/graphios_commands.cfg ${NAGIOS_HOME}/etc/objects/
sed -i "s|###GRAPHIOS_SPOOL###|${GRAPHIOS_SPOOL}|g" ${NAGIOS_HOME}/etc/objects/graphios_commands.cfg


#post config
cp ${GRAPHIOS_HOME}/graphios.cfg ${GRAPHIOS_HOME}/graphios.cfg.org
sleep 1
sed -i 's/enable_influxdb = False/enable_influxdb = True/g' ${GRAPHIOS_HOME}/graphios.cfg
echo "## InfluxDB Information of Nagios Status Data" >> ${GRAPHIOS_HOME}/graphios.cfg
echo "influxdb_servers = $INFLUXDB_SERVER:8086" >> ${GRAPHIOS_HOME}/graphios.cfg
echo "influxdb_db = $INFLUXDB_DB" >> ${GRAPHIOS_HOME}/graphios.cfg
echo "influxdb_user = $INFLUXDB_USER" >> ${GRAPHIOS_HOME}/graphios.cfg
echo "influxdb_password = $INFLUXDB_PASS" >> ${GRAPHIOS_HOME}/graphios.cfg
cat ${NAGIOS_CONF}/localhost.cfg > ${NAGIOS_HOME}/etc/objects/localhost.cfg
sed -i "s|###PREFIX_LOCALHOST###|${PREFIX_LOCALHOST}|g" ${NAGIOS_HOME}/etc/objects/localhost.cfg

#Log location
sed -i "s|\/usr\/local\/nagios\/var\/graphios.log|${GRAPHIOS_LOGS}\/graphios.log|g" ${GRAPHIOS_HOME}/graphios.cfg


