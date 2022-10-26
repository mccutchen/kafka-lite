#!/bin/bash

cat > ./kafka.properties <<EOL
broker.id=1
cluster.id=$KAFKA_CLUSTER_ID
listeners=PLAINTEXT://:$KAFKA_PORT
zookeeper.connect=localhost:$ZOOKEEPER_PORT
log.dirs=$KAFKA_DATA_DIR
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
EOL

cat > ./zookeeper.properties <<EOL
cluster.id=$KAFKA_CLUSTER_ID
dataDir=$ZOOKEEPER_DATA_DIR
clientPort=$ZOOKEEPER_PORT
maxClientCnxns=0
admin.enableServer=false
EOL

exec supervisord --nodaemon --configuration /etc/supervisord.conf
