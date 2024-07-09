#!/bin/bash

sudo sed -i '/bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo mysql << EOF
	CREATE USER '${db_user}'@'%' IDENTIFIED BY '${db_pass}';
	CREATE DATABASE IF NOT EXISTS ${db_name};
	GRANT ALL PRIVILEGES ON metabasedb.* TO '${db_user}'@'%';
	FLUSH PRIVILEGES;
EOF

cd tmp/

curl -LJO https://github.com/FrancoBertoldiMariglio/Teleinformatica/raw/main/caso_practico_2/google-mobility.sql.gz -o /tmp/google-mobility.sql.gz

gzip -d /tmp/google-mobility.sql.gz

sudo mysql ${db_name} < /tmp/google-mobility.sql

rm /tmp/google-mobility.sql 
