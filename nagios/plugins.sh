#!/bin/bash

echo "##### Install Nagios Plugins #####"

export NAGIOS_HOME="/app/nagios"

cd $NAGIOS_HOME
curl -L -O http://nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
tar xvf nagios-plugins-*.tar.gz
cd nagios-plugins-*
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl --prefix=${NAGIOS_HOME}
make
make install