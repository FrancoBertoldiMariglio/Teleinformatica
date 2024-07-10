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

log "Creating dashboard"
DASHBOARD_ID=$(curl -X POST http://localhost:3000/api/dashboard \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_TOKEN" \
  -d '{
    "name": "Mobility Dashboard",
    "description": "Mobility data for Mendoza Province, Capital Department"
  }' | jq -r '.id')

if [ -z "$DASHBOARD_ID" ]; then
    log "Failed to create dashboard. Exiting."
    exit 1
fi

log "Creating question"
QUESTION_ID=$(curl -X POST http://localhost:3000/api/card \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_TOKEN" \
  -d '{"name":"average mendoza","type":"question","dataset_query":{"database": '"$DB_ID"',"type":"query","query":{"source-table":9,"aggregation":[["avg",["field",83,{"base-type":"type/Integer"}]],["avg",["field",81,{"base-type":"type/Integer"}]],["avg",["field",72,{"base-type":"type/Integer"}]],["avg",["field",80,{"base-type":"type/Integer"}]],["avg",["field",78,{"base-type":"type/Integer"}]],["avg",["field",86,{"base-type":"type/Integer"}]]],"breakout":[["field",73,{"base-type":"type/DateTime","temporal-unit":"day"}]],"filter":["and",["=",["field",85,{"base-type":"type/Text"}],"Mendoza Province"],["=",["field",75,{"base-type":"type/Text"}],"Capital Department"],["between",["field",73,{"base-type":"type/DateTime"}],"2020-01-01","2020-12-31"]]}},"display":"area","description":null,"visualization_settings":{"stackable.stack_type":null,"graph.dimensions":["date"],"graph.metrics":["avg","avg_2","avg_3","avg_4","avg_5","avg_6"]},"collection_id":null,"collection_position":null,"result_metadata":[{"description":null,"semantic_type":null,"coercion_strategy":null,"unit":"day","name":"date","settings":null,"fk_target_field_id":null,"field_ref":["field",73,{"base-type":"type/DateTime","temporal-unit":"day"}],"effective_type":"type/Date","id":73,"visibility_type":"normal","display_name":"Date","fingerprint":{"global":{"distinct-count":321,"nil%":0},"type":{"type/DateTime":{"earliest":"2020-02-15T00:00:00Z","latest":"2020-12-31T00:00:00Z"}}},"base_type":"type/Date"},{"display_name":"Average of Retail And Recreation Percent Change From Baseline","semantic_type":null,"settings":null,"field_ref":["aggregation",0],"base_type":"type/Decimal","effective_type":"type/Decimal","name":"avg","fingerprint":{"global":{"distinct-count":95,"nil%":0},"type":{"type/Number":{"min":-96,"q1":-69.0857716560905,"q3":-42.84139629549865,"max":41,"sd":27.658547670628238,"avg":-52.29283489096573}}}},{"display_name":"Average of Grocery And Pharmacy Percent Change From Baseline","semantic_type":null,"settings":null,"field_ref":["aggregation",1],"base_type":"type/Decimal","effective_type":"type/Decimal","name":"avg_2","fingerprint":{"global":{"distinct-count":101,"nil%":0},"type":{"type/Number":{"min":-91,"q1":-30.805717884568125,"q3":0.5971624461628744,"max":83,"sd":26.054557250362603,"avg":-16.31152647975078}}}},{"display_name":"Average of Parks Percent Change From Baseline","semantic_type":null,"settings":null,"field_ref":["aggregation",2],"base_type":"type/Decimal","effective_type":"type/Decimal","name":"avg_3","fingerprint":{"global":{"distinct-count":94,"nil%":0},"type":{"type/Number":{"min":-99,"q1":-90.42656981021216,"q3":-50.86001194493218,"max":59,"sd":32.48307885753726,"avg":-60.49844236760124}}}},{"display_name":"Average of Transit Stations Percent Change From Baseline","semantic_type":null,"settings":null,"field_ref":["aggregation",3],"base_type":"type/Decimal","effective_type":"type/Decimal","name":"avg_4","fingerprint":{"global":{"distinct-count":86,"nil%":0},"type":{"type/Number":{"min":-90,"q1":-56.375,"q3":-39.62201759733446,"max":29,"sd":23.83605137258345,"avg":-45.16822429906542}}}},{"display_name":"Average of Workplaces Percent Change From Baseline","semantic_type":null,"settings":null,"field_ref":["aggregation",4],"base_type":"type/Decimal","effective_type":"type/Decimal","name":"avg_5","fingerprint":{"global":{"distinct-count":91,"nil%":0},"type":{"type/Number":{"min":-83,"q1":-29.76356457060072,"q3":-6.708333333333333,"max":33,"sd":24.104273707172357,"avg":-21.40809968847352}}}},{"display_name":"Average of Residential Percent Change From Baseline","semantic_type":null,"settings":null,"field_ref":["aggregation",5],"base_type":"type/Decimal","effective_type":"type/Decimal","name":"avg_6","fingerprint":{"global":{"distinct-count":42,"nil%":0},"type":{"type/Number":{"min":-3,"q1":11.41332798286476,"q3":20.054308789731966,"max":40,"sd":8.746244187259899,"avg":16.009345794392523}}}}]}' | jq -r '.id')

if [ -z "$QUESTION_ID" ]; then
    log "Failed to create question. Exiting."
    exit 1
fi
      
log "Adding question to dashboard"
curl -X POST http://localhost:3000/api/dashboard/$DASHBOARD_ID \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_TOKEN" \
  -d '{
    "cardId": '"$QUESTION_ID"',
    "sizeX": 24,
    "sizeY": 15,
    "row": 0,
    "col": 0
  }'

log "Script finished successfully"
