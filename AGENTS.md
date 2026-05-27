# Agentic Coding Instructions

## Overview

This repository uses Docker Swarm and Dokploy for deployments. Automated CI/CD is handled via GitHub Actions and MegaLinter.

## Instructions for Agents

- **Reference Documentation**: Always refer to [README.md](README.md) for the latest setup and configuration details.
- **Maintain Documentation**: Keep [README.md](README.md) and [AGENTS.md](AGENTS.md) updated as the project evolves.
- **Deployment logic**:
  - Staging deployments are triggered by PRs.
  - Production deployments are triggered by merges to `main`.
  - Use the `curl` command to trigger Dokploy deployments via its API.
- **Secrets**:
  - Never hardcode secrets.
  - Use environment variables and Doppler for secrets management.
- **Tools**:
  - Use the provided scripts in `scripts/` for infrastructure setup.
  - Ensure all scripts are idempotent.
- **Linting**:
  - Adhere to the configurations in `.editorconfig`, `.yamlfmt`, and `.pre-commit-config.yaml`.
  - MegaLinter will automatically fix issues in PRs.

## Verification

Before submitting any changes, ensure:

1. All linting checks pass.
2. The deployment workflow is updated if necessary.
3. Documentation reflects all changes accurately.
