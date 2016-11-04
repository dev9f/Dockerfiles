#!/bin/bash

export NAGIOS_HOME="/app/nagios"

echo "Nagios core Install"

cd ${NAGIOS_HOME}
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.2.2.tar.gz
tar xzf nagioscore.tar.gz
cd nagioscore-nagios-*
./configure --prefix=${NAGIOS_HOME}
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf
