FROM centos:7

#MAINTAINER heeminChae / version: 1.0

# Add Default User Account : suser / Change Password : root, suser
# RUN groupadd -g 500 -r suser && useradd -u 500 -r -m -g suser suser && \
#         echo "suser:S2curity" | chpasswd && \
#         echo "root:S2curity" | chpasswd

# Install default package
#RUN yum -y install tuned tune-util vim bzip2 gzip unzip tar git wget curl hostname sysvinit-tools util-linux net-tools epel-release openssh* sudo yum-utils
RUN yum -y install wget epel-release

# Install mysql package
RUN yum -y install http://repo.mysql.com/yum/mysql-5.5-community/el/7/x86_64/mysql-community-common-5.5.53-2.el7.x86_64.rpm && \
    yum -y install http://repo.mysql.com/yum/mysql-5.5-community/el/7/x86_64/mysql-community-libs-5.5.53-2.el7.x86_64.rpm && \
    yum -y install http://repo.mysql.com/yum/mysql-5.5-community/el/7/x86_64/mysql-community-client-5.5.53-2.el7.x86_64.rpm && \
    yum -y install http://repo.mysql.com/yum/mysql-5.5-community/el/7/x86_64/mysql-community-server-5.5.53-2.el7.x86_64.rpm && \
    yum -y install mysql mysql-server && \
    yum clean all

# sudo suser sshd
# RUN echo suser ALL=/etc/init.d/sshd >> /etc/sudoers
# RUN sed -i 's/Defaults    requiretty/\#Defaults    requiretty/g' /etc/sudoers

# TimeZone Change : KST
# RUN mv /etc/localtime /etc/localtime.bak && \
#         ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Set Env
ENV APP_HOME="/app" \
    WORK=/work

#make default directory
RUN mkdir -p $APP_HOME && mkdir -p $WORK
    # && chown -R suser:suser $APP_HOME

ADD ./post.sh $WORK/post.sh
ADD ./my.cnf    $WORK/my.cnf

# RUN echo %sudo        ALL=NOPASSWD: ALL >> /etc/sudoers
RUN chmod 755 $WORK/post.sh && chmod 755 $WORK/my.cnf

# mysql port
EXPOSE 3306

# Start Container
CMD ["/work/post.sh"]