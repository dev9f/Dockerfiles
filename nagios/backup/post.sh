#!/bin/bash


export APP_HOME="/app"
export WORK="/work"
export NAGIOS_HOME="/app/nagios"
export GRAPHIOS_HOME="/app/graphios"
export GRAPHIOS_LOGS="/app/graphios/logs"
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
    tar xvfz ${NAGIOS_WORK}/nagios.tar.gz
fi

#httpd start
service httpd start


#Install graphios
cd ${NAGIOS_WORK}

git clone https://github.com/shawn-sterling/graphios.git

cd ${NAGIOS_WORK}/graphios

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
cat ${NAGIOS_WORK}/graphios_commands.txt >> ${NAGIOS_HOME}/etc/nagios.cfg
sed -i "s|GRAPHIOS_SPOOL|${GRAPHIOS_SPOOL}|g" ${NAGIOS_HOME}/etc/nagios.cfg
mv ${NAGIOS_WORK}/graphios_commands.cfg ${NAGIOS_HOME}/etc/objects/
sed -i "s|GRAPHIOS_SPOOL|${GRAPHIOS_SPOOL}|g" ${NAGIOS_HOME}/etc/objects/graphios_commands.cfg


#post config
cp ${GRAPHIOS_HOME}/graphios.cfg ${GRAPHIOS_HOME}/graphios.cfg.org
sleep 1
sed -i 's/enable_influxdb = False/enable_influxdb = True/g' ${GRAPHIOS_HOME}/graphios.cfg
echo "## InfluxDB Information of Nagios Status Data" >> ${GRAPHIOS_HOME}/graphios.cfg
echo "influxdb_servers = $INFLUXDB_SERVER:8086" >> ${GRAPHIOS_HOME}/graphios.cfg
echo "influxdb_db = $INFLUXDB_DB" >> ${GRAPHIOS_HOME}/graphios.cfg
echo "influxdb_user = $INFLUXDB_USER" >> ${GRAPHIOS_HOME}/graphios.cfg
echo "influxdb_password = $INFLUXDB_PASS" >> ${GRAPHIOS_HOME}/graphios.cfg

#Log location
sed -i "s|\/usr\/local\/nagios\/var\/graphios.log|${GRAPHIOS_LOGS}\/graphios.log|g" ${GRAPHIOS_HOME}/graphios.cfg


 ## Graphios Start
nohup  ${GRAPHIOS_HOME}/graphios.py -v --backend=influxdb --config_file=${GRAPHIOS_HOME}/graphios.cfg &

# Nagios Start
${NAGIOS_HOME}/bin/nagios ${NAGIOS_HOME}/etc/nagios.cfg
