FROM alpine:3 AS downloader

RUN apk add --no-cache wget

RUN wget -O /postgresql-42.5.4.jar \
    https://repo1.maven.org/maven2/org/postgresql/postgresql/42.5.4/postgresql-42.5.4.jar

FROM apache/hive:4.0.1

COPY --from=downloader /postgresql-42.5.4.jar /opt/hadoop/share/hadoop/common/lib/

RUN \
    ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/

COPY --chown=1000 process-config.sh /
RUN chmod +x /process-config.sh

ENTRYPOINT ["sh", "-c", "/process-config.sh"]
