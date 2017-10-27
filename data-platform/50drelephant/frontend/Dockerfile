###
# Instructions - run these commands from 50drelephant directory
#
# Build command:
# cd 50drelephant && docker-compose build
#
# Run command:
# docker-compose up
# docker-compose start
#
# Then when it's up, you can connect to http://localhost:8080
#

FROM centos:latest

RUN yum install -y java-1.8.0-openjdk-devel wget unzip git which zip mariadb

RUN curl -O http://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12.zip \
 && unzip typesafe-activator-1.3.12.zip -d / \
 && rm typesafe-activator-1.3.12.zip \
 && chmod a+x /activator-dist-1.3.12/bin/activator
ENV PATH $PATH:/activator-dist-1.3.12/bin

## CONFIGURE ##
ENV HADOOP_VERSION	2.7.4
ENV SPARK_VERSION	2.1.0
ENV HADOOP_HOME		/usr/local/hadoop
ENV PATH		$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV ELEPHANT_CONF_DIR=/usr/dr-elephant/app-conf


## SETUP HADOOP CLIENT ##
# Hadoop Installation
RUN wget http://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz  && tar -zxf /hadoop-$HADOOP_VERSION.tar.gz && \
    rm /hadoop-$HADOOP_VERSION.tar.gz && mv hadoop-$HADOOP_VERSION /usr/local/hadoop && mkdir -p /usr/local/hadoop/logs

ENV YARN_HOME ${HADOOP_HOME}
ENV HADOOP_MAPRED_HOME ${HADOOP_HOME}
ENV HADOOP_COMMON_HOME ${HADOOP_HOME}
ENV HADOOP_HDFS_HOME ${HADOOP_HOME}
ENV HADOOP_PREFIX ${HADOOP_HOME}
ENV HADOOP_COMMON_LIB_NATIVE_DIR ${HADOOP_PREFIX}/lib/native
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_COMMON_LIB_NATIVE_DIR"
ENV PATH $HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

## BUILD AND INSTALL ##

ENV ELEPHANT_VERSION 2.0.15

RUN git clone https://github.com/jakhani/drelephant-demo.git drelephant-demo\
 && cd /drelephant-demo/drelephant \
 && unzip dr-elephant_2.10-$ELEPHANT_VERSION.zip -d /usr \
 && ln -s  /usr/dr-elephant-$ELEPHANT_VERSION /usr/dr-elephant \
 && rm -Rf /drelephant-demo

## Linked MySql container env vars are injected
# RUN cd /usr/dr-elephant \
# && sed -i -e "s/port=.*/port=\${http_port:-8080}/g"                              ./app-conf/elephant.conf \
# && sed -i -e "s/db_url=.*/db_url\=\${MYSQL_PORT_3306_TCP_ADDR:-dr-elephant-mysql}/g"     ./app-conf/elephant.conf \
# && sed -i -e "s/db_name=.*/db_name=\${MYSQL_ENV_MYSQL_DATABASE:-drelephant}/g"   ./app-conf/elephant.conf \
# && sed -i -e "s/db_user=.*/db_user=\${MYSQL_ENV_MYSQL_USER:-root}/g"             ./app-conf/elephant.conf \
# && sed -i -e "s/db_password=.*/db_password=\${MYSQL_ENV_MYSQL_PASSWORD:-drelephant}/g"   ./app-conf/elephant.conf \
# && sed -i -e 's@jvm_props=.*@jvm_args="-Devolutionplugin=disabled -DapplyEvolutions.default=false -J-XX:MaxPermSize=2g -J-XX:PermSize=1g -J-Xmx16g"@g' ./app-conf/elephant.conf

## RUN ##

#EXPOSE 8080

#VOLUME $ELEPHANT_CONF_DIR $HADOOP_CONF_DIR /usr/dr-elephant/logs

#CMD ["/usr/dr-elephant/bin/start.sh /usr/dr-elephant/app-conf/"]

COPY entrypoint.sh /
COPY start.sh /

VOLUME $HADOOP_HOME/etc/hadoop/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]
