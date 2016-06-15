FROM centos:6

MAINTAINER heeminChae / version: 1.0

# Add Default User Account : suser / Change Password : root, suser
RUN groupadd -g 500 -r suser && useradd -u 500 -r -m -g suser suser && \
        echo "suser:S2curity" | chpasswd && \
        echo "root:S2crity" | chpasswd

# Install default package
RUN yum -y install bzip2 gzip unzip tar git wget curl net-tools epel-release openssh* sudo && \
    yum -y install supervisor

# sudo suser sshd
RUN echo suser ALL=/etc/init.d/sshd >> /etc/sudoers
RUN sed -i 's/Defaults    requiretty/\#Defaults    requiretty/g' /etc/sudoers

# TimeZone Change : KST
RUN mv /etc/localtime /etc/localtime.bak && \
        ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Set Env
ENV APP_HOME="/app" \
    WORK="/work" \
    WORK_CONF="/work/conf" 

# Make default directory
RUN mkdir -p ${APP_HOME} && mkdir -p ${WORK} && chown -R suser:suser ${APP_HOME} 

# Install influxdb
RUN yum -y install https://s3.amazonaws.com/influxdb/influxdb-0.8.8-1.x86_64.rpm && yum clean all

ADD ./post.sh	${WORK}/post.sh
ADD ./conf ${WORK_CONF}
RUN chmod 755 ${WORK}/post.sh


EXPOSE 8083
EXPOSE 8086

CMD ["/work/post.sh"]
