#!/bin/bash

# Note: hard-coded cluster.id generated like so:
# python3 -c 'import uuid; print(uuid.uuid4())' | base64 | cut -b 1-22
cat > ./kafka.properties <<EOL
broker.id=1
cluster.id=NTllYjBlY2YtZWRmYy00Nj
listeners=PLAINTEXT://:$KAFKA_PORT
zookeeper.connect=localhost:$ZOOKEEPER_PORT
log.dirs=$KAFKA_LOGS_DIR
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
EOL

cat > ./zookeeper.properties <<EOL
dataDir=$ZOOKEEPER_DATA_DIR
clientPort=$ZOOKEEPER_PORT
maxClientCnxns=0
admin.enableServer=false
EOL

exec supervisord --nodaemon --configuration /etc/supervisord.conf
