#!/bin/bash

export NAGIOS_HOME="/app/nagios"

echo "Nagios core Install"

cd ${NAGIOS_HOME}
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.0.tar.gz
tar zxf nagios-*.tar.gz
cd nagios-*
./configure --with-command-group=nagcmd --prefix=${NAGIOS_HOME}
make all
make install
make install-commandmode
make install-init
make install-config
make install-webconf
