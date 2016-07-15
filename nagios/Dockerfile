FROM centos:6

MAINTAINER heeminChae / version: 1.0

# Add Default User Account : suser / Change Password : root, suser
RUN groupadd -g 500 -r suser && useradd -u 500 -r -m -g suser suser && \
        echo "suser:S2curity" | chpasswd && \
        echo "root:S2crity" | chpasswd

# Install default package
RUN yum -y install tar git wget curl net-tools epel-release openssh* yum-utils sudo 

# sudo suser sshd
RUN echo suser ALL=/etc/init.d/sshd >> /etc/sudoers
RUN sed -i 's/Defaults    requiretty/\#Defaults    requiretty/g' /etc/sudoers

# TimeZone Change : KST
RUN mv /etc/localtime /etc/localtime.bak && \
        ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Set Env
ENV APP_HOME="/app" \
    WORK="/work" \
    NAGIOS_HOME="/app/nagios"  \
    NAGIOS_INIT="/work/init" \
    NAGIOS_CONF="/work/conf" \
    NAGIOS_USER="nagiosadmin" \
    NAGIOS_PASS="qwe123" \
    GRAPHIOS_HOME="/app/nagios/graphios" \
    GRAPHIOS_LOGS="/app/nagios/graphios/logs" \
    GRAPHIOS_SPOOL="/var/spool/nagios/graphios" 


# Make default directory
RUN mkdir -p ${APP_HOME} && mkdir -p ${WORK} && mkdir -p ${NAGIOS_HOME} && chown -R suser:suser ${APP_HOME}

# install Prerequisites
RUN yum install httpd php php-cli gcc glibc glibc-common gd gd-devel net-snmp openssl-devel wget unzip -y

# Create user and group for Nagios to use
RUN useradd nagios && groupadd nagcmd && usermod -a -G nagcmd nagios && usermod -a -G nagcmd apache

### For nagios-dev ##################################
# Install SW Packages
RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && \
    yum-config-manager --enable remi-php56,remi

# Install Apache, PHP
RUN yum -y install php php-gd php-mysql php-mcrypt php-mbstring php-pdo php-xml php-fpm

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer
### For nagios-dev ##################################


# ADD Scripts
ADD ./post.sh  ${WORK}/post.sh
ADD ./init ${WORK}/init
ADD ./conf ${WORK}/conf

# Permission Update
RUN chmod 755 ${NAGIOS_INIT}/nagiosInstall.sh ${NAGIOS_INIT}/nagiosPlug.sh ${NAGIOS_INIT}/nrpe.sh ${NAGIOS_INIT}/graphios.sh ${WORK}/post.sh


# Install Nagios shall start
RUN ${NAGIOS_INIT}/nagiosInstall.sh


# Install Nagios Plugins
RUN ${NAGIOS_INIT}/nagiosPlug.sh

# Install NRPE
RUN ${NAGIOS_INIT}/nrpe.sh

# Install Graphios
RUN ${NAGIOS_INIT}/graphios.sh

# compress Application
RUN cd ${WORK} && tar cvfz ${WORK}/nagios.tar.gz ${NAGIOS_HOME} && rm -rf ${NAGIOS_HOME}

EXPOSE 80

CMD ["/work/post.sh"]
