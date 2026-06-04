# docker-stacks

Automations with docker stacks

## OCI Resource Manager — ARM Free Tier VPS

The `oci-rm/` directory contains a modular Terraform stack for OCI Resource
Manager that provisions an Ampere A1 (ARM) Always Free VPS (4 OCPU / 24 GB RAM
/ 200 GB boot volume).

The cloud-init template (`oci-rm/templates/cloud-init.yaml`) configures
iptables (ports 80, 443, 9443), installs Docker, and adds the `ubuntu`
user to the docker group. The Terraform stack uses it automatically.

Required inputs: **Compartment**, **SSH Public Key**, and optionally
**Cloud-init Configuration** (defaults to `oci-rm/templates/cloud-init.yaml`).

### Deploy via OCI Console

```bash
cd oci-rm && zip -r ../oci-rm-stack.zip . && cd ..
```

Upload `oci-rm-stack.zip` via **Developer Services → Resource Manager → Stacks
→ Create Stack**, fill in the form, and click **Apply**.

### Deploy via OCI CLI

```bash
# Update existing stack config
STACK_ID=<stack-ocid> bash bin/oci-rm-stack-update.sh
```

### Apply via cron (out-of-capacity retry)

`bin/oci-rm-stack-apply.sh` retries the apply job idempotently — skips if
already succeeded or in progress, exits 0 on capacity errors.

```bash
# Cron example (every 10 minutes)
*/10 * * * * STACK_ID=<stack-ocid> /path/to/bin/oci-rm-stack-apply.sh
```

## Docker Stacks

### Public Stack

The `public/` directory contains public-facing utility services behind a Caddy
reverse proxy with automatic HTTPS. Services are exposed via wildcard subdomains
(`*.DOMAIN`) using Caddy Docker labels, sharing the `public_default` network
with Caddy.

#### Authentication

[TinyAuth] provides forward authentication via OAuth (GitHub/Google). Services
use the `reverse_proxy_auth` Caddy snippet to require login. Configuration is
in `public/.env.example`.

[TinyAuth]: https://tinyauth.app

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
Services requiring authentication (nzbhydra2, nzbdav) use TinyAuth forward
auth via the `reverse_proxy_auth` Caddy snippet.
