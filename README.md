# docker-stacks

Automations with Docker Swarm and Dokploy.

## Overview

This repository provides a reproducible setup for deploying services using Docker Swarm and Dokploy on Oracle Cloud Free Tier (ARM).

## Features

- **Idempotent Setup**: A script to install Docker, initialize Swarm, and deploy Dokploy.
- **CI/CD**: GitHub Actions for automated linting (MegaLinter) and deployment.
- **Environment Separation**: Automated staging deployments for PRs and production deployments for commits to `main`.
- **Secrets Management**: Integration with Doppler for secure secret handling.
- **Dynamic Routing**: Traefik-based routing with DuckDNS subdomains.

## Getting Started

### 1. Provision Oracle Cloud Instance
- Create an ARM-based instance (A1.Flex) in Oracle Cloud.
- Ensure you have SSH access.

### 2. Install Dokploy
Run the following command on your server:
```bash
curl -sSL https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/scripts/install-dokploy.sh | bash
```
Alternatively, clone the repo and run the script manually.

### 3. Configure DuckDNS
- Create a domain on [DuckDNS](https://www.duckdns.org/).
- Point your domain to your Oracle Cloud instance's public IP.

### 4. Configure Dokploy
- Access Dokploy at `http://your-ip:3000`.
- Set up your admin account.
- Configure Traefik and Let's Encrypt.
- Create a Project and two Environments: `staging` and `production`.
- Deploy the `whoami` stack from `stacks/whoami.yml`.

### 5. Secrets Management (Doppler)
- Create a project in Doppler.
- Add your secrets (e.g., `DOMAIN`).
- Set the `DOPPLER_TOKEN` in GitHub Actions secrets.

### 6. GitHub Actions Secrets
Configure the following secrets in your GitHub repository:
- `DOKPLOY_URL`: Your Dokploy instance URL.
- `DOKPLOY_API_KEY`: Generated from Dokploy.
- `DOKPLOY_STAGING_APP_ID`: The ID of your staging application/project in Dokploy.
- `DOKPLOY_PROD_APP_ID`: The ID of your production application/project in Dokploy.
- `DOPPLER_TOKEN`: Your Doppler Service Token.

## Deployment Flow

- **Staging**: Any Pull Request to the `main` branch triggers a deployment to the staging environment.
- **Production**: Merging to the `main` branch triggers a deployment to the production environment.
- **Linting**: MegaLinter runs on every PR and automatically commits fixes back to the PR branch.

## Reference
Inspired by [yxtay/dotfiles](https://github.com/yxtay/dotfiles).
