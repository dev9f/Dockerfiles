#!/bin/bash

export NAGIOS_HOME="/app/nagios"

echo "Nagios Plugins Install"

cd ${NAGIOS_HOME}
wget http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
tar zxf nagios-plugins-2.1.1.tar.gz
cd nagios-plugins-2.1.1
./configure --prefix=${NAGIOS_HOME} --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make all
make install

