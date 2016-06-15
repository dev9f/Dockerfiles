FROM centos:6

MAINTAINER heeminChae / version: 1.0

# Add Default User Account : suser / Change Password : root, suser
RUN groupadd -g 500 -r suser && useradd -u 500 -r -m -g suser suser && \
        echo "suser:S2curity" | chpasswd && \
        echo "root:S2curity" | chpasswd

# Install default package
RUN yum -y install tar git wget curl net-tools epel-release openssh* sudo gcc glibc glibc-common && yum clean all

# sudo suser sshd
RUN echo suser ALL=/etc/init.d/sshd >> /etc/sudoers
RUN sed -i 's/Defaults    requiretty/\#Defaults    requiretty/g' /etc/sudoers

# TimeZone Change : KST
RUN mv /etc/localtime /etc/localtime.bak && \
        ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Set Env
ENV APP_HOME="/app" \
    WORK="/work" 

# Make default directory
RUN mkdir -p ${APP_HOME} && mkdir -p ${WORK} && chown -R suser:suser ${APP_HOME}

# Install grafana, supervisor
RUN yum -y install https://grafanarel.s3.amazonaws.com/builds/grafana-3.0.4-1464167696.x86_64.rpm && yum clean all

ADD ./conf	/work/conf
ADD ./post.sh 	${WORK}/post.sh
RUN chmod 755	${WORK}/post.sh


EXPOSE	3000

CMD ["/work/post.sh"]
