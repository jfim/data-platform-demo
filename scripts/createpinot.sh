#!/bin/sh
curl -X DELETE http://localhost:10005/tables/flights_REALTIME
curl -X DELETE http://localhost:10005/schemas/flightDataSchema
curl -X POST -F flightDataSchema=@flight-data-schema.json http://localhost:10005/schemas
curl -X POST -d @table-config.json http://localhost:10005/tables
