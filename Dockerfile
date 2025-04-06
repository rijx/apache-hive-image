#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM alpine:3 AS archive
ARG HADOOP_VERSION
ARG HIVE_VERSION
ARG TEZ_VERSION
RUN apk add --no-cache wget
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -xzvf hadoop-$HADOOP_VERSION.tar.gz -C /opt/ && \
    mv /opt/hadoop-$HADOOP_VERSION /opt/hadoop && \
    rm -rf /opt/hadoop/share/doc/* && \
    wget -O /opt/hadoop/share/hadoop/common/lib/postgresql-42.5.4.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.5.4/postgresql-42.5.4.jar && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/ && \
    wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
    tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz -C /opt/ && \
    mv /opt/apache-hive-$HIVE_VERSION-bin /opt/hive && \
    rm -rf /opt/hive/jdbc/* && \
    wget https://archive.apache.org/dist/tez/$TEZ_VERSION/apache-tez-$TEZ_VERSION-bin.tar.gz && \
    tar -xzvf apache-tez-$TEZ_VERSION-bin.tar.gz -C /opt && \
    mv /opt/apache-tez-$TEZ_VERSION-bin /opt/tez && \
    rm -rf /opt/tez/share/*

FROM openjdk:8-jre-slim AS run

RUN set -ex; \
    apt-get update; \
    apt-get -y install procps gettext-base; \
    rm -rf /var/lib/apt/lists/*

COPY --from=archive /opt/hadoop /opt/hadoop
COPY --from=archive /opt/hive /opt/hive
COPY --from=archive /opt/tez /opt/tez

ARG HIVE_VERSION

ENV HADOOP_HOME=/opt/hadoop \
    HIVE_HOME=/opt/hive \
    TEZ_HOME=/opt/tez \
    HIVE_VER=$HIVE_VERSION

ENV PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ARG UID=1000
RUN adduser --no-create-home --disabled-login --gecos "" --uid $UID hive && \
    chown hive /opt/tez && \
    chown hive /opt/hive && \
    chown hive /opt/hadoop && \
    chown hive /opt/hive/conf && \
    mkdir -p /opt/hive/data/warehouse && \
    chown hive /opt/hive/data/warehouse && \
    mkdir -p /home/hive/.beeline && \
    chown hive /home/hive/.beeline

USER hive
WORKDIR /opt/hive
EXPOSE 10000 10002 9083

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
