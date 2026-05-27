# docker-stacks

Automations with docker stacks

## Scaffolding

This project uses several tools to ensure code quality and consistency:

- **MegaLinter**: Runs in GitHub Actions to perform comprehensive linting on
  every Pull Request.
- **Pre-commit**: Local git hooks to format and lint code before committing.
- **Renovate**: Automatically manages and updates dependencies.
- **EditorConfig**: Ensures consistent coding styles across different editors
  and IDEs.
- **Yamlfmt**: Specifically handles YAML file formatting.
- **GitHub Actions**: Workflows for CI, security scans (OSSF Scorecard,
  Semgrep, etc.), and automerge.

## Dokploy Setup on OCI

This repository includes a script to automate the setup of Dokploy on an Oracle
Cloud Infrastructure (OCI) Ubuntu instance.

### Initialization Script

The `scripts/init.sh` script performs the following actions:

1. Updates and upgrades system packages.
2. Configures `iptables` to allow traffic on essential ports:
    - **80 (TCP)**: HTTP traffic.
    - **443 (TCP/UDP)**: HTTPS traffic.
    - **3000 (TCP)**: Dokploy Dashboard.
3. Ensures `iptables` rules are persistent across reboots using
`iptables-persistent`.
4. Installs Dokploy if it is not already present, or updates it if it is.

### Usage

#### As Cloud-init User Data

When creating a new OCI instance, you can provide the contents of
`scripts/init.sh` as the **Cloud-init script** (User Data) to automate the
entire setup process.

#### Manual Execution

You can also run the script manually on an existing Ubuntu instance:

```bash
sudo ./scripts/init.sh
```

### Managing Deployments with Dokploy

Once Dokploy is installed, you can access the dashboard at
`http://<your-instance-ip>:3000`.

Dokploy allows you to easily manage and deploy:

- **Docker Compose Stacks**: Deploy complex multi-container applications by
providing your `docker-compose.yml` directly in the Dokploy interface.
- **Applications**: Deploy web applications from GitHub, GitLab, or Bitbucket.
- **Databases**: Easily provision and manage PostgreSQL, MySQL, MongoDB, and
Redis instances.
