# docker-stacks

Automations with Docker Swarm and Dokploy.

## Overview

This repository provides a reproducible setup for deploying services using Docker Swarm and Dokploy on Oracle Cloud Free Tier (ARM).

## Features

- **Idempotent Setup**: A script to install Docker, initialize Swarm, and deploy Dokploy.
- **CI/CD**: GitHub Actions for automated linting (MegaLinter) and deployment.
- **Environment Separation**: Automated staging deployments for PRs and production deployments for commits to `main`.
- **Modular Stacks**: Services are defined in separate files within the `stacks/` directory for better organization.
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

### 3. Configure DuckDNS

- Create a domain on [DuckDNS](https://www.duckdns.org/).
- Point your domain to your Oracle Cloud instance's public IP.

### 4. Configure Dokploy

- Access Dokploy at `http://your-ip:3000`.
- Set up your admin account and configure Traefik.
- Create a Project and two Environments: `staging` and `production`.

### 5. Modular Stacks

To add a new service:

1. Create a new `service-name.yml` in the `stacks/` directory.
2. In Dokploy, create a new "Compose Stack" and point it to the raw URL of your file in GitHub or paste the content.
3. Use environment variables (like `DOMAIN`) provided via Doppler.

### 6. Secrets (Doppler)

- Add `DOPPLER_TOKEN` to GitHub Actions secrets.
- The CI/CD workflow will fetch secrets and pass them to Dokploy deployments.

## Deployment Flow

- **Staging**: Pull Requests to `main` trigger a deployment to staging.
- **Production**: Merging to `main` triggers a deployment to production.
- **Linting**: MegaLinter runs on every PR and automatically fixes formatting issues.

## Reference

Inspired by [yxtay/dotfiles](https://github.com/yxtay/dotfiles).
