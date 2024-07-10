#!/bin/bash

LOG_FILE="/home/ubuntu/vm_db.log"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "Starting script"

log "Updating apt repository"
sudo apt-get update

log 'Changing binding address'
sudo sed -i '/bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

log 'Creating User'
if sudo mysql << EOF
    CREATE USER '${db_user}'@'%' IDENTIFIED BY '${db_pass}';
    CREATE DATABASE IF NOT EXISTS ${db_name};
    GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%';
    FLUSH PRIVILEGES;
EOF
then
    log "User and database created successfully"
else
    log "Failed to create user and database"
fi

cd /tmp

log 'Downloading SQL file'
if curl -LJO https://github.com/FrancoBertoldiMariglio/Teleinformatica/raw/main/caso_practico_2/google-mobility.sql.gz -o google-mobility.sql.gz; then
    log "SQL file downloaded successfully"
else
    log "Failed to download SQL file"
fi

log 'Decompressing SQL file'
sudo gzip -d google-mobility.sql.gz

if [[ ! -f google-mobility.sql ]]; then
	log "Failed to decompress SQL file"
	exit 1
fi

log 'Importing SQL file'
sudo mysql ${db_name} < google-mobility.sql

row_count=$(sudo mysql ${db_name} -e "SELECT COUNT(*) FROM mobility;" | tail -n 1)
if [[ $row_count -gt 0 ]]; then
    log "Data correctly inserted into the database"
else
    log "Error inserting data into the database"
fi

log 'Removing SQL file'
rm /tmp/google-mobility.sql

log "Script finished succesfully"
