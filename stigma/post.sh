#!/bin/bash

# Dockerfile ENV
#APP_HOME="/app"
#WORK="/work"

set -m
#STIGMA ENV Check
: "${STIGMA_HOME:=/app/stigma}"

if [ -e ${STIGMA_HOME} ]
then
    echo "+++++ ${STIGMA_HOME} already exists."
else
    echo "+++++ ${STIGMA_HOME} does not exists ..."
    echo "+++++ Laravel App Directory create and copy config files..."
    cp ${WORK}/conf/httpd-vhosts.conf /etc/httpd/conf.d/

    ## Laravel Setting
    cd /app && git clone https://github.com/stigma2/stigma2-dev.git ${STIGMA_HOME}
    cd ${STIGMA_HOME} && chmod -R 777 storage && composer install
    cd ${STIGMA_HOME} && php artisan key:generate && php artisan migrate && php artisan db:seed
fi


# Application Start - Httpd
/usr/sbin/httpd -D FOREGROUND

