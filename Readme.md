# Keycloak with Nginx and PostgreSQL in Docker-compose

This project provides a ready-to-deploy setup for Keycloak with Nginx as a reverse proxy and PostgreSQL as the database, all containerized with Docker-compose. It's aimed at simplifying the deployment process for development and production environments.

## Features

- **Keycloak**: Fully configured and ready for integration with your applications.
- **Nginx**: Setup as a reverse proxy for Keycloak, enhancing security and load balancing.
- **PostgreSQL**: Used as a persistent database for Keycloak data.

## Prerequisites

Before starting, ensure you have Docker and Docker-compose installed on your machine. To create and maintain ssl certificates also install certbot, so we can request let's encrypt certificates.

## Quick Start

1. Run `docker swarm init` to enable swarm mode
1. Clone the repository
1. Navigate to the project directory
1. Create an `.env`-file containing the following sensitive information:
   ```
   ADMINPWD=keycloakAdminPwd
   POSTGRESPWD=PostgresPwd
   HOSTNAME=hostname
   ```
1. Point a dns A record to the defined hsotname and request a certificate for your domain
   ```
   certbot certonly
   ```
1. Run `sudo deploy.sh`

## Let's encrypt

Add details to certificate process

## Deployment script

We use a deployment script which will export the `.env` variables because docker stack does not support this.
