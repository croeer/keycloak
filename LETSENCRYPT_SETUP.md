# Let's Encrypt Setup with Automatic Renewal

This setup configures automatic Let's Encrypt certificate renewal for your Keycloak instance using certbot and nginx.

## Prerequisites

1. Your domain must point to this server (DNS A record)
2. Ports 80 and 443 must be accessible from the internet
3. Docker and Docker Compose must be installed

## Environment Variables

Add these to your environment or `.env` file:

```bash
# Your domain name
TF_VAR_IDP_HOSTNAME=idp.ku0.de

# Email for Let's Encrypt notifications
CERTBOT_EMAIL=your-email@example.com

# Other existing variables
POSTGRESPWD=your-postgres-password
ADMINPWD=your-keycloak-admin-password
```

## Initial Setup

1. **Make the setup script executable:**

   ```bash
   chmod +x setup-letsencrypt.sh
   ```

2. **Run the setup script:**

   ```bash
   ./setup-letsencrypt.sh
   ```

   This script will:

   - Create necessary directories
   - Start nginx
   - Obtain initial Let's Encrypt certificates (staging first, then production)
   - Set up automatic renewal via cron job
   - Configure nginx to reload after certificate renewal

## Automatic Renewal

The setup creates a cron job that runs daily at 12:00 PM to:

- Check if certificates need renewal
- Renew certificates if needed
- Reload nginx to use new certificates
- Log all activities to `certbot-renewal.log`

## Manual Renewal

To manually renew certificates:

```bash
./renew-certs.sh
```

## Monitoring

- Check renewal logs: `tail -f certbot-renewal.log`
- View cron jobs: `crontab -l`
- Check certificate status: `docker-compose run --rm certbot certificates`

## Troubleshooting

### Certificate renewal fails

1. Check if your domain is accessible from the internet
2. Verify DNS settings point to this server
3. Check firewall settings for ports 80 and 443
4. Review logs: `docker-compose logs nginx` and `docker-compose logs certbot`

### Nginx fails to reload

1. Check nginx configuration: `docker-compose exec nginx nginx -t`
2. Verify certificate files exist: `ls -la /etc/letsencrypt/live/your-domain/`

### Remove cron job

```bash
crontab -e
# Remove the line containing "renew-certs.sh"
```

## Files Created/Modified

- `docker-compose.yml` - Added certbot service
- `data/nginx/keycloak.conf` - Added ACME challenge handling
- `renew-certs.sh` - Certificate renewal script
- `setup-letsencrypt.sh` - Initial setup script
- `docker-compose.init.yml` - Override for initial certificate setup
- `certbot-renewal.log` - Renewal logs (created after first run)

## Security Notes

- Certificates are stored in `/etc/letsencrypt/` on the host
- The webroot challenge files are served from `./data/certbot/www/`
- Nginx automatically redirects HTTP to HTTPS
- SSL configuration includes modern cipher suites and protocols
