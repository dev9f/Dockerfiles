#!/bin/bash

echo "##### Install NRPE #####"

export NAGIOS_HOME="/app/nagios"


cd ${NAGIOS_HOME}
wget --no-check-certificate https://github.com/NagiosEnterprises/nrpe/archive/3.0.1.tar.gz
tar zxf 3*
cd nrpe*
./configure --enable-command-args --prefix=${NAGIOS_HOME}
make all
make install-groups-users
make install
make install-config

echo >> /etc/services
echo '# Nagios services' >> /etc/services
echo 'nrpe    5666/tcp' >> /etc/services

make install-init

sed -i 's/^dont_blame_nrpe=.*/dont_blame_nrpe=1/g' ${NAGIOS_HOME}/etc/nrpe.cfg