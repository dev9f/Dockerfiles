#!/bin/bash

export NAGIOS_HOME="/app/nagios"

echo "Nagios Plugins Install"

cd ${NAGIOS_HOME}
wget http://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz
tar xvf nagios-plugins-*.tar.gz
cd nagios-plugins-*
#./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl --prefix=${NAGIOS_HOME}
./configure --with-nagios-user=nagios --with-nagios-group=nagios --prefix=${NAGIOS_HOME}
make
make install
cd ~

## delete source files
rm -rf ${NAGIOS_HOME}/nagios-plugins*
