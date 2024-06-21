FROM alpine:3.16

# See VERSIONS in this repo for the versions used when building this image.
#
# See https://kafka.apache.org/downloads for available Kafka versions and the
# Scala versions with which they are built.
ARG KAFKA_VERSION
ARG SCALA_VERSION
ARG KAFKA_TARBALL=https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN apk add --no-cache bash curl openjdk17-jre-headless supervisor \
    && mkdir -p /opt/kafka \
    && curl -sSL ${KAFKA_TARBALL} | tar -zxv -C /opt/kafka --strip-components=1

ENV PATH=/opt/kafka/bin:${PATH}

# Note: Default KAFKA_CLUSTER_ID generated like so:
# echo "00000000-0000-0000-0000-000000000000" | base64 | cut -b 1-22
ENV KAFKA_CLUSTER_ID=MDAwMDAwMDAtMDAwMC0wMD \
    KAFKA_DATA_DIR=/var/lib/kafka/data \
    KAFKA_NOAUTH_PORT=9092 \
    KAFKA_PORT=9093 \
    ZOOKEEPER_DATA_DIR=/var/lib/zookeeper/data \
    ZOOKEEPER_PORT=2181 \
    LOG_DIR=/var/log/kafka

# By default, the entire container will exit if any component fails. Set this
# to false or 0 to leave the container running for debugging purposes.
ENV EXIT_ON_FAILURE=true

RUN addgroup kafka \
    && adduser -D -s /bin/bash -G kafka kafka \
    && mkdir -p ${KAFKA_DATA_DIR} \
    && mkdir -p ${ZOOKEEPER_DATA_DIR} \
    && mkdir -p ${LOG_DIR} \
    && chown -R kafka:kafka ${KAFKA_DATA_DIR} \
    && chown -R kafka:kafka ${ZOOKEEPER_DATA_DIR} \
    && chown -R kafka:kafka ${LOG_DIR}

WORKDIR /home/kafka
COPY start-kafka-lite.sh eventlistener.py ./
COPY supervisord.conf /etc/supervisord.conf

VOLUME ${KAFKA_DATA_DIR}
VOLUME ${ZOOKEEPER_DATA_DIR}

EXPOSE ${KAFKA_PORT}
EXPOSE ${ZOOKEEPER_PORT}
EXPOSE ${KAFKA_NOAUTH_PORT}

USER kafka
CMD ["./start-kafka-lite.sh"]
