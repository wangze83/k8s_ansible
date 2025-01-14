FROM centos:7
LABEL maintainer="wangze1@wz.cn"
RUN echo "Asia/Shanghai" >> /etc/timezone
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN mkdir -p  /etc/apt/ && touch sources.list
RUN echo " " > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian jessie main" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian jessie-updates main" >> /etc/apt/sources.list

RUN yum clean all && \
     yum -y update && \
    yum install -y net-tools iproute openssh-clients openssh-server wget bind-utils fuse curl

RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
  chmod +x /usr/local/bin/jq

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

RUN mkdir -p /polefs/bin /polefs/conf /polefs/mnt /polefs/data /polefs/logs
RUN rpm -ivh https://download.infrasre.wz.net/s3/polefs/polefs-client-4.0.1-20.el7.centos.x86_64.rpm
RUN cp -a /usr/bin/polefs-client /polefs/bin/polefs-client
COPY start.sh /polefs/bin/start.sh
ENTRYPOINT ["/bin/tini", "--", "sh", "-c", "sh /polefs/bin/start.sh"]