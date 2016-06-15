#!/bin/bash

export WORK="/work"
export GRAPHIOS_HOME="/app/nagios/graphios"


#Install graphios
cd ${WORK}

git clone https://github.com/shawn-sterling/graphios.git

cd ${WORK}/graphios

mkdir -p ${GRAPHIOS_HOME}

cp graphios*.py ${GRAPHIOS_HOME}
cp graphios.cfg ${GRAPHIOS_HOME}


