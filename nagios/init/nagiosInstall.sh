#!/bin/bash

export NAGIOS_HOME="/app/nagios"

echo "Nagios core Install"

cd ${NAGIOS_HOME}
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz
tar zxf nagios-4.1.1.tar.gz
cd nagios-4.1.1
./configure --prefix=${NAGIOS_HOME} --with-command-group=nagcmd
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf

