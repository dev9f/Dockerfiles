#!/bin/bash

echo "##### Install Nagios Core #####"

export NAGIOS_HOME="/app/nagios"
export NAGIOS_USER="nagiosadmin"
export NAGIOS_PASSWD="nagiosadmin"

cd $NAGIOS_HOME
curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz
tar zxf nagios-*.tar.gz
cd nagios-*
./configure --with-command-group=nagcmd --prefix=${NAGIOS_HOME}
make all
make install
make install-commandmode
make install-init
make install-config
make install-webconf
usermod -G nagcmd apache

sleep 1
echo -e "define command{\n" \
        "\tcommand_name check_nrpe\n" \
        "\tcommand_line \$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -c \$ARG1\$\n" \
        "}" >> ${NAGIOS_HOME}/etc/objects/commands.cfg
htpasswd -cb ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOS_USER} ${NAGIOS_PASSWD}