FROM centos:7

#MAINTAINER heeminChae / version: 1.0

# Add Default User Account : suser / Change Password : root, suser
# RUN groupadd -g 500 -r suser && useradd -u 500 -r -m -g suser suser && \
#     echo "suser:S2curity" | chpasswd && \
#     echo "root:S2crity" | chpasswd


# sudo suser sshd
# RUN echo suser ALL=/etc/init.d/sshd >> /etc/sudoers
# RUN sed -i 's/Defaults    requiretty/\#Defaults    requiretty/g' /etc/sudoers

# TimeZone Change : KST
# RUN mv /etc/localtime /etc/localtime.bak && \
#     ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

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
RUN mkdir -p ${APP_HOME} && mkdir -p ${WORK} && mkdir -p ${NAGIOS_HOME}
    # && chown -R suser:suser ${APP_HOME}

# Install Default, Prerequisites packages
RUN yum -y install tar git wget epel-release openssh-server && \
    yum -y install httpd gcc glibc glibc-common unzip httpd php gd gd-devel make openssl openssl-devel perl file && \
    yum clean all

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''

# Create user and group for Nagios to use
RUN useradd nagios && usermod -a -G nagios nagios && usermod -a -G nagios apache && \
    echo "root:S2curity" | chpasswd


# ADD Config files
ADD ./config ${WORK}

# Permission Update, Install Nagios shall start
RUN chmod 755 ${NAGIOS_INIT}/nagiosInstall.sh ${NAGIOS_INIT}/nagiosPlug.sh ${NAGIOS_INIT}/graphios.sh ${WORK}/post.sh && \
    ${NAGIOS_INIT}/nagiosInstall.sh && \
    ${NAGIOS_INIT}/nagiosPlug.sh && \
    ${NAGIOS_INIT}/nrpe.sh && \
    ${NAGIOS_INIT}/graphios.sh

# compress Application
RUN cd ${WORK} && \
    tar cvfz ${WORK}/nagios.tar.gz ${NAGIOS_HOME} && \
    rm -rf ${NAGIOS_HOME}

EXPOSE 22
EXPOSE 80

CMD ["/work/post.sh"]
