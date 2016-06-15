#!/bin/bash

echo "##### Install NRPE #####"

export NAGIOS_HOME="/app/nagios"


cd ${NAGIOS_HOME}
curl -L -O http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
tar xvf nrpe-*.tar.gz
cd nrpe-*
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu --prefix=${NAGIOS_HOME}
make all
make install
make install-xinetd
make install-daemon-config
