#!/bin/bash

sudo apt-get update
sudo apt-get install -y wget apt-transport-https
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt-get update
sudo apt-get install -y temurin-11-jre

cd /home/ubuntu
mkdir -p metabase
cd metabase/
wget https://downloads.metabase.com/v0.46.6/metabase.jar

export MB_DB_TYPE=mysql
export MB_DB_DBNAME=${db_name}
export MB_DB_PORT=3306
export MB_DB_USER=${db_user}
export MB_DB_PASS=${db_pass}
export MB_DB_HOST=${db_ip}

#env > /home/ubuntu/metabase/env_vars.log

#sudo java -jar metabase.jar

sudo java -DMB_DB_TYPE=mysql \
     -DMB_DB_DBNAME=${db_name} \
     -DMB_DB_PORT=3306 \
     -DMB_DB_USER=${db_user} \
     -DMB_DB_PASS=${db_pass} \
     -DMB_DB_HOST=${db_ip} \
     -jar metabase.jar

