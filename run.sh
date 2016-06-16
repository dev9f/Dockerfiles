#!/bin/bash

# ENV Check
DATA_PATH=$1

if [ -z ${DATA_PATH} ]; then
	echo "Insert [/Persistance/Volume/Path] for Stigma docker images..."
	echo "ex) sh pre-init.sh /data/DockerVol"
	exit
else
	echo "+++++ Persistence Volume Path : ${DATA_PATH}"
	echo ""
fi

if [ -e ${DATA_PATH} ]; then
    echo "+++++ ${DATA_PATH} already exists."
else
    echo "+++++ ${DATA_PATH} does not exists..."
    echo "+++++ Persistence volume path create..."
    
    mkdir -p ${DATA_PATH}
    echo "+++++ Persistence volume path create success..."
fi

echo "+++++ Persistence volume path ownership change [nobody:nobody]..."
chown -R nobody:nobody ${DATA_PATH}

echo ""
echo "+++++ Stigma docker images start using docker-compose..."
exec docker-compose -f stigma.yml up
