FROM centos:6

MAINTAINER heeminChae / version: 1.0

# Add Default User Account : stigma / Change Password : root, stigma
RUN groupadd -g 500 -r stigma && useradd -u 500 -r -m -g stigma stigma && \
        echo "stigma:S2curity" | chpasswd && \
        echo "root:Su2crity" | chpasswd

# sudo stigma sshd
RUN echo stigma ALL=/etc/init.d/sshd >> /etc/sudoers
RUN sed -i 's/Defaults    requiretty/\#Defaults    requiretty/g' /etc/sudoers

# TimeZone Change : KST
RUN mv /etc/localtime /etc/localtime.bak && \
        ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Install Default Package
RUN yum -y install epel-release net-tools wget curl tar git

# Install Build Dependencies
RUN yum -y install gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel xinetd unzip

# Install Prerequisites
RUN yum -y install httpd php php-mysql

# Create User and Group for Nagios to Use
RUN useradd nagios && \
        groupadd nagcmd && \
        usermod -a -G nagcmd nagios

# Set Env
ENV PROJECT_HOME="/app" \
        WORK="/work"

# Make default directory
RUN mkdir -p $PROJECT_HOME && mkdir -p $WORK && \
        chown -R stigma:stigma $PROJECT_HOME

# 
ADD ./nagios.sh $WORK/nagios.sh
ADD ./plugins.sh $WORK/plugins.sh
ADD ./nrpe.sh $WORK/nrpe.sh
ADD ./graphios.sh $WORK/graphios.sh
ADD ./post.sh $WORK/post.sh

# 
RUN chmod 755 $WORK/nagios.sh $WORK/plugins.sh $WORK/nrpe.sh $WORK/graphios.sh $WORK/post.sh

# Install Nagios
RUN $WORK/nagios.sh

# Install Nagios Plugins
RUN $WORK/plugins.sh

# Install NRPE
RUN $WORK/nrpe.sh

# Install Graphios
RUN $WORK/graphios.sh

# 
RUN yum clean all

# 
EXPOSE 80

# 
CMD ["$WORK/post.sh"]