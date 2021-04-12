ARG HADOOP_VERSION=3.2.2
ARG BASE=pilillo/hadoop:${HADOOP_VERSION}

FROM ${BASE} as BASE
ARG HADOOP_VERSION
ARG INSTALLATION_DIR="/opt"

ARG HIVE_VERSION=3.1.2
ARG HIVE_DOWNLOAD_URL=https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz

ARG HIVE_USER=hive
ARG HIVE_UID=186

ARG HIVE_DIR_NAME=hive
ENV HIVE_HOME=${INSTALLATION_DIR}/${HIVE_DIR_NAME}

WORKDIR ${INSTALLATION_DIR}

USER root

RUN useradd -u ${HIVE_UID} ${HIVE_USER} \
    && usermod -a -G ${HADOOP_GROUP} ${HIVE_USER}

RUN curl ${HIVE_DOWNLOAD_URL} | tar xvz -C ${INSTALLATION_DIR} \
    && mv apache-hive-$HIVE_VERSION-bin ${HIVE_DIR_NAME} \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# solve guava mismatch between hadoop/hive libs
RUN rm ${HIVE_HOME}/lib/guava*.jar \ 
    && cp ${HADOOP_HOME}/share/hadoop/common/lib/guava*-jre.jar ${HIVE_HOME}/lib/

# cleanup some files
RUN rm -rf examples

RUN chown -R ${HIVE_USER}:${HADOOP_GROUP} ${HIVE_HOME}

WORKDIR ${HIVE_HOME}
USER ${HIVE_USER}

# hiveserver
EXPOSE 10000
EXPOSE 10002

ENTRYPOINT ["/opt/hive/bin/hiveserver2"]