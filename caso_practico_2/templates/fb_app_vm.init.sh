#!/bin/bash

sudo apt-get update

sudo apt-get install -y wget apt-transport-https
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt-get update
sudo apt-get install -y temurin-11-jre

cd /home/ubuntu

mkdir metabase

cd metabase/

wget https://downloads.metabase.com/v0.50.10/metabase.jar

export MB_DB_TYPE=mysql
export MB_DB_DBNAME=${db_name}
export MB_DB_PORT=3306
export MB_DB_USER=${db_user}
export MB_DB_PASS=${db_pass}
export MB_DB_HOST=${db_ip}

java -jar metabase.jar

