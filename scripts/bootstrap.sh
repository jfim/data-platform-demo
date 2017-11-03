#!/bin/bash

# Setup kafka topic
echo "Creating topic: Flight"
kubectl exec -n data-platform kafka-0 -- bin/kafka-topics.sh --create --zookeeper zk-0.zk-headless:2181/kafka --replication-factor 1 --partitions 1 --topic Flight

# Download data
echo "Downloading data"
kubectl exec -n yarn-cluster hdfs-nn-0 -- rm -rf data
kubectl exec -n yarn-cluster hdfs-nn-0 -- curl https://jean-francois.im/odsc/data.zip -o data.zip
kubectl exec -n yarn-cluster hdfs-nn-0 -- unzip data.zip

# Put to hdfs
echo "Putting data to hdfs"
kubectl exec -n yarn-cluster hdfs-nn-0 -- hdfs dfs -rm -r -skipTrash /data
kubectl exec -n yarn-cluster hdfs-nn-0 -- hdfs dfs -put data /
kubectl exec -n yarn-cluster hdfs-nn-0 -- hdfs dfs -mv /data/*.csv /data/input/
kubectl exec -n yarn-cluster hdfs-nn-0 -- hdfs dfs -rm -skipTrash /data/input/test.csv
echo "Cleaning up"
kubectl exec -n yarn-cluster hdfs-nn-0 -- rm -rf data
kubectl exec -n yarn-cluster hdfs-nn-0 -- rm -r data.zip

echo "Bootstrap is done!"
