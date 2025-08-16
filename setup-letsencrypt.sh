#!/bin/bash

# Setup script for Let's Encrypt with automatic renewal

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Check if required environment variables are set
if [ -z "$TF_VAR_IDP_HOSTNAME" ]; then
    error "TF_VAR_IDP_HOSTNAME environment variable is not set"
    exit 1
fi

if [ -z "$CERTBOT_EMAIL" ]; then
    error "CERTBOT_EMAIL environment variable is not set"
    exit 1
fi

log "Setting up Let's Encrypt for domain: $TF_VAR_IDP_HOSTNAME"
log "Email: $CERTBOT_EMAIL"

# Create necessary directories
log "Creating necessary directories..."
mkdir -p data/certbot/www
mkdir -p data/nginx/ssl

# Make scripts executable
chmod +x renew-certs.sh

# Start nginx first
log "Starting nginx..."
docker-compose up -d nginx

# Wait for nginx to be ready
log "Waiting for nginx to be ready..."
sleep 10

# Get initial certificate (using staging first to test)
log "Getting initial certificate (staging environment)..."
docker-compose -f docker-compose.yml -f docker-compose.init.yml run --rm certbot

# Check if staging certificate was successful
if [ $? -eq 0 ]; then
    log "Staging certificate obtained successfully"
    
    # Now get production certificate
    log "Getting production certificate..."
    docker-compose -f docker-compose.yml -f docker-compose.init.yml run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email ${CERTBOT_EMAIL} --agree-tos --no-eff-email -d ${TF_VAR_IDP_HOSTNAME}
    
    if [ $? -eq 0 ]; then
        log "Production certificate obtained successfully"
        
        # Reload nginx to use new certificates
        log "Reloading nginx with new certificates..."
        docker-compose exec nginx nginx -s reload
        
        # Set up automatic renewal
        log "Setting up automatic renewal..."
        
        # Create cron job for certificate renewal
        CRON_JOB="0 12 * * * cd $(pwd) && ./renew-certs.sh >> ./certbot-renewal.log 2>&1"
        
        # Check if cron job already exists
        if crontab -l 2>/dev/null | grep -q "renew-certs.sh"; then
            warn "Cron job for certificate renewal already exists"
        else
            # Add cron job
            (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
            log "Cron job added for daily certificate renewal at 12:00 PM"
        fi
        
        log "Setup completed successfully!"
        log "Certificates will be automatically renewed daily at 12:00 PM"
        log "You can check renewal logs in: ./certbot-renewal.log"
        
    else
        error "Failed to obtain production certificate"
        exit 1
    fi
else
    error "Failed to obtain staging certificate"
    exit 1
fi
