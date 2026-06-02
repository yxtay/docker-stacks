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

## OCI Resource Manager — ARM Free Tier VPS

The `oci-rm/` directory contains a modular Terraform stack for OCI Resource
Manager that provisions an Ampere A1 (ARM) Always Free VPS, including VCN,
subnet, internet gateway, security rules, and compute instance.

### Always Free limits

| Resource      | Limit                               |
|---------------|-------------------------------------|
| Shape         | `VM.Standard.A1.Flex`               |
| OCPUs         | 4 total across all A1 instances     |
| Memory        | 24 GB total across all A1 instances |
| Block storage | 200 GB total                        |

Defaults: 4 OCPU / 24 GB RAM / 200 GB boot volume (Max Always Free).

### Features

- **Modular Architecture**: Clean separation of concerns with network and
  compute modules.
- **Structured Cloud-init**: Automatically updates packages and installs `curl`
  and `iptables-persistent`.
- **Configurable Networking**: Easily specify additional TCP/UDP ports for
  ingress.
- **ORM Optimized**: Enhanced `schema.yaml` with logical grouping and
  descriptive tooltips.

### Variables

All variables have sensible defaults. Required inputs:

- **Compartment** — target OCI compartment
- **SSH Public Key** — key for instance access
- **Cloud-init Configuration** (optional) — paste `oci-rm/templates/cloud-init.yaml`
  to customize the instance setup. Defaults to the provided template.

### Deploy via OCI Console (recommended)

1. Zip the stack:

    ```bash
    cd oci-rm && zip -r ../oci-rm-stack.zip . && cd ..
    ```

2. Open **Developer Services → Resource Manager → Stacks** in the OCI Console.
3. Click **Create Stack** → **Upload a .zip file** → select `oci-rm-stack.zip`.
4. Fill in the form (variables pre-populated with defaults).
5. Click **Apply**.

### Deploy via OCI CLI

Requires OCI CLI configured (`oci setup config`).

**Update** an existing stack's Terraform config:

```bash
STACK_ID=<stack-ocid> bash bin/oci-rm-stack-update.sh
```

### Apply via cron (out-of-capacity retry)

A1.Flex Free Tier capacity is limited and apply jobs may fail with
`500-InternalError, Out of host capacity`. Since networking resources are
created first and are idempotent, re-applying the same stack retries only
the instance.

`bin/oci-rm-stack-apply.sh` is designed for cron:

- Skips if previous apply already succeeded (idempotent)
- Skips if a job is already in progress
- Prints logs from previous failed job before retrying
- Exits 0 on capacity errors (no cron failure spam)

```bash
# Run once
STACK_ID=<stack-ocid> bash bin/oci-rm-stack-apply.sh

# Run at interval in terminal (every 10 minutes)
export STACK_ID=<stack-ocid>
watch -n 600 bash bin/oci-rm-stack-apply.sh

# Cron example (every 10 minutes)
*/10 * * * * STACK_ID=<stack-ocid> /path/to/bin/oci-rm-stack-apply.sh
```

## Docker Setup on OCI

This repository includes a cloud-init configuration to automate the setup of a
Docker-ready Ubuntu instance on Oracle Cloud Infrastructure (OCI).

### Cloud-init Configuration

The `oci-rm/templates/cloud-init.yaml` configuration performs the following actions:

1. Updates and upgrades system packages.
1. Configures `iptables` to allow traffic on essential ports:
    - **80 (TCP)**: HTTP.
    - **443 (TCP/UDP)**: HTTPS (including HTTP/3).
    - **9443 (TCP)**: Portainer dashboard (HTTPS).
1. Installs Docker using the official `get.docker.com` script.
1. Adds the `ubuntu` user to the `docker` group.
1. Reboots to apply all changes.

### Usage

#### As Cloud-init User Data

When creating a new OCI instance, the Terraform stack automatically uses
the template. You can also manually provide the contents of
`oci-rm/templates/cloud-init.yaml` as the **Cloud-init script** (User Data).

## Docker Stacks

### Public Stack

The `public/` directory contains public-facing utility services behind a Caddy
reverse proxy with automatic HTTPS. Services are exposed via wildcard subdomains
(`*.DOMAIN`) using Caddy Docker labels, sharing the `public_default` network
with Caddy.

### Docker Stack

The `docker/` directory contains monitoring and maintenance services
for docker containers.

### Portainer Stack

The `portainer/` directory contains the Portainer CE container management UI.
Use `bin/portainer-up.sh` in cron to setup GitOps.

```bash
# Cron example (every 5 minutes)
*/5 * * * * /path/to/bin/portainer-up.sh
```

### Usenet Stack

The `usenet/` directory contains a Usenet streaming and indexing stack.

## Security

### Security Headers

The Caddy configuration includes a `security_headers` snippet that implements
industry-standard security headers based on recommendations from:

- [OWASP HTTP Headers Cheat Sheet][owasp]
- [Mozilla Web Security Guidelines][mozilla]

These headers are imported by default in the wildcard subdomain block
(`*.{$DOMAIN}`).

[owasp]: https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html
[mozilla]: https://infosec.mozilla.org/guidelines/web_security
