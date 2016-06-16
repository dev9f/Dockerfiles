FROM centos:6

MAINTAINER heeminChae / version: 1.0

# Add Default User Account : stigma / Change Password : root, stigma
RUN groupadd -g 500 -r stigma && useradd -u 500 -r -m -g stigma stigma && \
        echo "stigma:S2curity" | chpasswd && \
        echo "root:Su2crity" | chpasswd

# Install default package
RUN yum -y install tuned tune-util vim bzip2 gzip unzip tar git wget curl hostname sysvinit-tools util-linux net-tools epel-release openssh* sudo yum-utils

# sudo stigma sshd
RUN echo stigma ALL=/etc/init.d/sshd >> /etc/sudoers
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
RUN mkdir -p ${APP_HOME} && mkdir -p ${WORK} && chown -R stigma:stigma ${APP_HOME}

# install Prerequisites
RUN yum install httpd php php-cli gcc glibc glibc-common gd gd-devel net-snmp openssl-devel wget unzip -y

# Create user and group for Nagios to use
RUN useradd nagios && groupadd nagcmd && usermod -a -G nagcmd nagios && usermod -a -G nagcmd apache

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
