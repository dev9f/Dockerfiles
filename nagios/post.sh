#!/bin/bash

echo "\n##### Running #####\n"

export NAGIOS_HOME="/app/nagios"

#if [ -e ${NAGIOS_HOME} ]
#then
#    echo "${NAGIOS_HOME} already exists."
#else
#    echo "${NAGIOS_HOME} does not exists."
#    tar xvfz $WORK/nagios.tar.gz
#fi

chkconfig httpd on
chkconfig nagios on

service httpd restart
service nagios restart
service xinetd restart