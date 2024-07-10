#!/bin/bash

LOG_FILE="/home/ubuntu/vm_lb.log"
APP_URL="http://${app_ip}:3000"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

check_app_connection() {
    log "Checking connection to application at $APP_URL"
    sleep 5
    if curl -sSf -m 5 -o /dev/null -w "200" $APP_URL | grep -q 200; then
        log "Connection to application successful"
        return 0
    else
        log "Failed to connect to application"
        return 1
    fi
}

log "Starting script"

log "Updating apt repository"
sudo apt-get update

log "Deleting default nginx configuration"
sudo rm -f /etc/nginx/sites-enabled/default

log "Configuring nginx as load balancer"
sudo tee /etc/nginx/conf.d/lb.conf << EOF
server {
    listen 80;
    location / {
        proxy_pass $APP_URL;
    }
}
EOF

log "Restarting nginx"
sudo service nginx restart

if check_app_connection; then
    log "Load balancer configured and successfully connected to the application"
else
    log "Load balancer configuration failed to connect to the application"
fi

log "Script finished successfully"
