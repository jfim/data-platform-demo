#!/bin/sh
curl -d '{ 
  "id": "1", 
  "name": "FlightCSV", 
  "schema_type": "CSV", 
  "urn": "csv:///data/FlightCSV", 
  "source": "HDFS" 
}' -X POST http://localhost:10002/wherehows/dataset/1

curl -d '{ 
  "id": "2", 
  "name": "Flight", 
  "schema_type": "CSV", 
  "urn": "kafka:///Flight", 
  "source": "Kafka" 
}' -X POST http://localhost:10002/wherehows/dataset/2

curl -d '{ 
  "id": "3", 
  "name": "Flight", 
  "schema_type": "AVRO", 
  "urn": "hdfs:///data/FlightAvro", 
  "source": "HDFS" 
}' -X POST http://localhost:10002/wherehows/dataset/3
