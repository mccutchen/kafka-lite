#!/bin/bash

# Create Kafka properties file
cat > ./kafka.properties <<EOL
authorizer.class.name=kafka.security.authorizer.AclAuthorizer
broker.id=1
cluster.id=$KAFKA_CLUSTER_ID
zookeeper.connect=localhost:$ZOOKEEPER_PORT
log.dirs=$KAFKA_DATA_DIR
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
EOL

if [ "$KAFKA_ENABLE_SASL" ]; then
echo "enable sasl"
    cat >> ./kafka.properties <<EOL
listeners=SASL_PLAINTEXT://:$KAFKA_PORT,PLAINTEXT://:$KAFKA_NOAUTH_PORT
super.users=User:admin
sasl.enabled.mechanisms=PLAIN
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.mechanism.inter.broker.protocol=PLAIN

EOL

# Create JAAS configuration file for Kafka
cat > ./kafka_jaas.conf <<EOL
KafkaServer {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="admin-secret"
  user_admin="admin-secret";
};

EOL
# Export JAAS configuration file location
export KAFKA_OPTS="-Djava.security.auth.login.config=/home/kafka/kafka_jaas.conf"
    
else
cat >> ./kafka.properties <<EOL
listeners=PLAINTEXT://:$KAFKA_PORT
EOL
fi

cat > ./zookeeper.properties <<EOL
cluster.id=$KAFKA_CLUSTER_ID
dataDir=$ZOOKEEPER_DATA_DIR
clientPort=$ZOOKEEPER_PORT
maxClientCnxns=0
admin.enableServer=false
EOL

# Start Kafka and Zookeeper using supervisord
exec supervisord --nodaemon --configuration /etc/supervisord.conf
