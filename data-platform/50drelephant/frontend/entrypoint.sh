#!/bin/bash

db_url=mysql.data-platform
db_name=drelephant
db_user=root
db_password=password

until mysql -h "$db_url" -u$db_user -p$db_password -e 'create database $db_name;'; do
  >&2 echo "MySQL is unavailable - sleeping. Unable to create database."
  sleep 1
done

until mysql -h "$db_url" -u$db_user -p$db_password -D$db_name -e'show tables;'; do
  >&2 echo "MySQL is unavailable - sleeping. Unable to connect with database."
  sleep 1
done

until mysql -h "$db_url" -u$db_user -p$db_password -D$db_name < /usr/dr-elephant-data/setup.sql; do
  >&2 echo "MySQL is unavailable - sleeping. Unable to create tables."
  sleep 1
exec "$@"
