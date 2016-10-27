FROM centos:7

MAINTAINER Seongtaeyang / version: 1.0

# Add Default User Account : suser / Change Password : root, suser
# RUN groupadd -g 500 -r suser && useradd -u 500 -r -m -g suser suser && \
#         echo "suser:S2curity" | chpasswd && \
#         echo "root:S2curity" | chpasswd

# Install default package
RUN yum -y install tar git wget curl net-tools epel-release openssh* yum-utils sudo 

# sudo suser sshd
# RUN echo suser ALL=/etc/init.d/sshd >> /etc/sudoers
RUN echo "apache  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN sed -i 's/Defaults    requiretty/\#Defaults    requiretty/g' /etc/sudoers

# TimeZone Change : KST
# RUN mv /etc/localtime /etc/localtime.bak && \
#         ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Set Env
ENV APP_HOME="/app" \
    WORK="/work" \
    WORK_CONF="/work/conf" 


# Make default directory
# RUN mkdir -p $APP_HOME && mkdir -p $WORK && chown -R suser:suser $APP_HOME 
RUN mkdir -p $APP_HOME && mkdir -p $WORK

# Install SW Packages
RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum-config-manager --enable remi-php56,remi

# Install Apache, PHP
RUN yum -y install httpd mysql php php-gd php-mysql php-mcrypt php-mbstring php-pdo php-xml php-fpm

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Install GlusterFS gdeploy. LATEST at 2016-09-22
RUN yum -y install ansible python-argparse python-pip python-wheel PyYAML python-setuptools && \
    pip install --upgrade pip && \
    pip install Jinja2 && \
    wget http://download.gluster.org/pub/gluster/gdeploy/2.0.1-1/CENTOS7/gdeploy-2.0.1-1.el7.centos.noarch.rpm && \
    yum -y install gdeploy-2.0.1-1.el7.centos.noarch.rpm

# Copy stigma
ADD /tmp/stigma/ ${WORK}/stigma

# Config file copy & Change owner and access permission
ADD ./post.sh	${WORK}/post.sh
ADD ./conf ${WORK_CONF}
RUN chmod 755 ${WORK}/post.sh

EXPOSE 22
EXPOSE 80

# Start Container
CMD ["/work/post.sh"]
