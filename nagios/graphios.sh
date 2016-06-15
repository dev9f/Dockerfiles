#!/bin/bash

echo "##### Install Graphios #####"

export NAGIOS_HOME="/app/nagios"
export GRAPHIOS_SPOOL="\/var\/spool\/graphios"
export INFLUXDB_SERVER="127.0.0.1:8086"
export INFLUXDB_DB="metrics"
export INFLUXDB_USER="root"
export INFLUXDB_PASSWD="root"

cd $NAGIOS_HOME
git clone https://github.com/shawn-sterling/graphios.git
echo "cfg_file="${NAGIOS_HOME}"/etc/objects/graphios_commands.cfg" >> ${NAGIOS_HOME}/etc/nagios.cfg
sed -i "s/process_performance_data=0/process_performance_data=1/g" ${NAGIOS_HOME}/etc/nagios.cfg
cat <<'EOF' >> ${NAGIOS_HOME}/etc/nagios.cfg
service_perfdata_file=GRAPHIOS_SPOOL/service-perfdata
service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tSERVICESTATE::$SERVICESTATE$\tSERVICESTATETYPE::$SERVICESTATETYPE$\tGRAPHITEPREFIX::$_SERVICEGRAPHITEPREFIX$\tGRAPHITEPOSTFIX::$_SERVICEGRAPHITEPOSTFIX$

service_perfdata_file_mode=a
service_perfdata_file_processing_interval=15
service_perfdata_file_processing_command=graphite_perf_service

host_perfdata_file=GRAPHIOS_SPOOL/host-perfdata
host_perfdata_file_template=DATATYPE::HOSTPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tHOSTPERFDATA::$HOSTPERFDATA$\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tGRAPHITEPREFIX::$_HOSTGRAPHITEPREFIX$\tGRAPHITEPOSTFIX::$_HOSTGRAPHITEPOSTFIX$

host_perfdata_file_mode=a
host_perfdata_file_processing_interval=15
host_perfdata_file_processing_command=graphite_perf_host
EOF
sed -i "s/GRAPHIOS_SPOOL/"${GRAPHIOS_SPOOL}"/g" ${NAGIOS_HOME}/etc/nagios.cfg
mkdir -p ${GRAPHIOS_SPOOL}
chmod 775 ${GRAPHIOS_SPOOL} && chown nagios:nagcmd ${GRAPHIOS_SPOOL}
cat <<'EOF' >> ${NAGIOS_HOME}/etc/objects/graphios_commands.cfg
define command {
        command_name    graphite_perf_host
        command_line    /bin/mv GRAPHIOS_SPOOL/host-perfdata GRAPHIOS_SPOOL/host-perfdata.$TIMET$
}

define command {
        command_name    graphite_perf_service
        command_line    /bin/mv GRAPHIOS_SPOOL/service-perfdata GRAPHIOS_SPOOL/service-perfdata.$TIMET$
}
EOF
sed -i "s/GRAPHIOS_SPOOL/"${GRAPHIOS_SPOOL}"/g" ${NAGIOS_HOME}/etc/objects/graphios_commands.cfg
sed -i "s/spool_directory =/#spool_directory =/g" $NAGIOS_HOME/graphios/graphios.cfg
sed -i "s/enable_influxdb = False/enable_influxdb = True/g" $NAGIOS_HOME/graphios/graphios.cfg
echo "spool_directory = "${GRAPHIOS_SPOOL} >> $NAGIOS_HOME/graphios/graphios.cfg
echo "influxdb_servers = "${INFLUXDB_SERVER} >> $NAGIOS_HOME/graphios/graphios.cfg
echo "influxdb_db = "${INFLUXDB_DB} >> $NAGIOS_HOME/graphios/graphios.cfg
echo "influxdb_user = "${INFLUXDB_USER} >> $NAGIOS_HOME/graphios/graphios.cfg
echo "influxdb_password = "${INFLUXDB_PASSWD} >> $NAGIOS_HOME/graphios/graphios.cfg