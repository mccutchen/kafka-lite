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

# enable SASL authenticated listener and unauthenticated listener
listeners=SASL_PLAINTEXT://:$KAFKA_PORT,PLAINTEXT://:$KAFKA_NOAUTH_PORT

# configure SASL authentication with "admin" and "user" users
sasl.enabled.mechanisms=PLAIN
listener.security.protocol.map=SASL_PLAINTEXT:SASL_PLAINTEXT,PLAINTEXT:PLAINTEXT
listener.name.sasl_plaintext.plain.sasl.enabled.mechanisms=PLAIN
listener.name.sasl_plaintext.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
    username="admin" \
    password="admin" \
    user_admin="admin" \
    user_user="user";
super.users=User:admin

# allow anonymous users full admin permissions during migration period
allow.everyone.if.no.acl.found=true
EOL

cat > ./zookeeper.properties <<EOL
cluster.id=$KAFKA_CLUSTER_ID
dataDir=$ZOOKEEPER_DATA_DIR
clientPort=$ZOOKEEPER_PORT
maxClientCnxns=0
admin.enableServer=false
EOL

# Start Kafka and Zookeeper using supervisord
exec supervisord --nodaemon --configuration /etc/supervisord.conf
