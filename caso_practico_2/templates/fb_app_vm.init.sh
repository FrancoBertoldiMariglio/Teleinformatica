#!/bin/bash

LOG_FILE="/home/ubuntu/vm_app.log"

JAVA_OUTPUT="/home/ubuntu/java_output.log"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "Starting script"

log "Updating apt repository"
sudo apt-get update 

log "Installing wget and apt-transport-https"
sudo apt-get install -y wget apt-transport-https 

log "Adding Adoptium GPG key"
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add - 

log "Adding Adoptium repository"
echo "deb [arch=$(dpkg --print-architecture)] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

log "Updating apt repository again"
sudo apt-get update 

log "Installing Temurin 11 JRE"
sudo apt-get install -y temurin-11-jre 

log "Creating Metabase directory"
cd /home/ubuntu
mkdir -p metabase 
cd metabase/

log "Downloading Metabase"
wget https://downloads.metabase.com/v0.50.10/metabase.jar 

if ! command -v jq &> /dev/null; then
    log "Installing jq"
    apt-get update 
    apt-get install -y jq 
    if [ $? -ne 0 ]; then
        log "Error installing jq"
        exit 1
    fi
fi

check_ping() {
    log "Checking ICMP ping to $1"
    if ping -c 1 $1 &> /dev/null; then
        log "ICMP ping to $1 successful"
        return 0
    else
        log "ICMP ping to $1 failed, waiting to retry..."
        sleep 10
        return 1
    fi
}

while ! check_ping ${db_ip}; do
    log "Retrying ICMP ping to ${db_ip}"
done

log "Starting Metabase"
sudo java -jar metabase.jar &>> $JAVA_OUTPUT &

wait_for_metabase() {
    log "Waiting for Metabase to be ready"
    while ! curl -s http://localhost:3000/api/health | grep -q "ok"; do
        sleep 10
    done
}

wait_for_metabase

log "Getting setup token"
SETUP_TOKEN=$(curl -s -m 5 -X GET \
        -H "Content-Type: application/json" \
        http://localhost:3000/api/session/properties \
        | jq -r '.["setup-token"]') >> $LOG_FILE

log "Setting up Metabase"
SETUP_RESPONSE=$(curl -s -X POST http://localhost:3000/api/setup \
  -H "Content-Type: application/json" \
  -d '{"token":"'$SETUP_TOKEN'","user":{"password_confirm":"'${db_pass}'","password":"'${db_pass}'","site_name":"Universidad de Mendoza","email":"f.bertoldi@alumno.um.edu.ar","last_name":"Bertoldi","first_name":"Franco"},"prefs":{"site_name":"Universidad de Mendoza","site_locale":"en"}}') >> $LOG_FILE

log "Creating session token"
SESSION_TOKEN=$(curl -X POST http://localhost:3000/api/session \
  -H "Content-Type: application/json" \
  -d '{
    "username": "f.bertoldi@alumno.um.edu.ar",
    "password": "'"${db_pass}"'"
  }' | jq -r '.id') >> $LOG_FILE

if [ -z "$SESSION_TOKEN" ]; then
    log "Error creating session token"
    exit 1
fi

log "Adding database to Metabase"
DB_ID=$(curl -X POST http://localhost:3000/api/database \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_TOKEN" \
  -d '{"is_on_demand":false,"is_full_sync":true,"is_sample":false,"cache_ttl":null,"refingerprint":false,"auto_run_queries":true,"schedules":{},"details":{"host":"'${db_ip}'","port":3306,"dbname":"'${db_name}'","user":"'${db_user}'","password":"'${db_pass}'","ssl":false,"tunnel-enabled":false,"advanced-options":false},"name":"mobility","engine":"mysql"}' | jq -r '.id') >> $LOG_FILE

if [ -z "$DB_ID" ]; then
    log "Error adding database to Metabase"
    exit 1
fi

log "Script finished successfully"
