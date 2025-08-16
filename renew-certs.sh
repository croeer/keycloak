#!/bin/bash

# Script to renew Let's Encrypt certificates and reload nginx

# Set your domain and email
DOMAIN=${TF_VAR_IDP_HOSTNAME:-idp.ku0.de}
EMAIL=${CERTBOT_EMAIL}

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if certificates need renewal
log "Checking certificate renewal for $DOMAIN"

# Run certbot renewal
docker-compose run --rm certbot renew

# Check if renewal was successful
if [ $? -eq 0 ]; then
    log "Certificate renewal successful"
    
    # Reload nginx to pick up new certificates
    log "Reloading nginx"
    docker-compose exec nginx nginx -s reload
    
    if [ $? -eq 0 ]; then
        log "Nginx reloaded successfully"
    else
        log "ERROR: Failed to reload nginx"
        exit 1
    fi
else
    log "ERROR: Certificate renewal failed"
    exit 1
fi

log "Certificate renewal process completed"
