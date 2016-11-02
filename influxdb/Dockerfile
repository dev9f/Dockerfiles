FROM centos:7

#MAINTAINER heeminChae / version: 1.0

# Add Default User Account : suser / Change Password : root, suser
# RUN groupadd -g 500 -r suser && useradd -u 500 -r -m -g suser suser && \
#         echo "suser:S2curity" | chpasswd && \
#         echo "root:S2crity" | chpasswd

# Install default package
# RUN yum -y install bzip2 gzip unzip tar git wget curl net-tools epel-release openssh* sudo && \
#     yum -y install supervisor
RUN yum -y install wget curl epel-release supervisor

# sudo suser sshd
# RUN echo suser ALL=/etc/init.d/sshd >> /etc/sudoers
# RUN sed -i 's/Defaults    requiretty/\#Defaults    requiretty/g' /etc/sudoers

# TimeZone Change : KST
# RUN mv /etc/localtime /etc/localtime.bak && \
#         ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Set Env
ENV APP_HOME="/app" \
    WORK="/work" \
    WORK_CONF="/work/conf" 

# Make default directory
RUN mkdir -p ${APP_HOME} && mkdir -p ${WORK}
    # && chown -R suser:suser ${APP_HOME} 

# Install influxdb
#RUN yum -y install https://s3.amazonaws.com/influxdb/influxdb-0.8.8-1.x86_64.rpm && yum clean all
#RUN wget -P $WORK https://s3.amazonaws.com/influxdb/influxdb-0.9.3-1.x86_64.rpm && \
#    yum localinstall -y $WORK/influxdb-0.9.3-1.x86_64.rpm
# RUN wget https://dl.influxdata.com/influxdb/releases/influxdb-0.13.0.x86_64.rpm && \
#     yum -y localinstall influxdb-0.13.0.x86_64.rpm
RUN cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF && yum -y install influxdb

ADD ./post.sh	${WORK}/post.sh
ADD ./conf ${WORK_CONF}
RUN chmod 755 ${WORK}/post.sh


EXPOSE 8083
EXPOSE 8086
# EXPOSE 8088

CMD ["/work/post.sh"]
