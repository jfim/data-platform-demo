#!/bin/bash

db_url=mysql.data-platform
db_name=drelephant
db_user=root
db_password=password

mysql -h "$db_url" -u$db_user -p$db_password -e 'CREATE DATABASE IF NOT EXISTS drelephant;'

mysql -h "$db_url" -u$db_user -p$db_password -D$db_name < /usr/dr-elephant/setup.sql
sleep 100

mysql -h "$db_url" -u$db_user -p$db_password -D$db_name -e'show tables;'
exec "$@"
