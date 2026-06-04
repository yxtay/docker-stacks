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

`bin/oci-rm-stack-apply.sh` retries apply idempotently — skips when already
succeeded or in progress, and only retries after capacity-related failures.

```bash
# Cron example (every 10 minutes)
*/10 * * * * STACK_ID=<stack-ocid> /path/to/bin/oci-rm-stack-apply.sh
```

## Docker Stacks

All stacks join the `public_default` external network and use Caddy for
reverse proxy with automatic HTTPS via DuckDNS. Services are exposed via
wildcard subdomains (`*.DOMAIN`). [TinyAuth] provides forward authentication
via OAuth (GitHub/Google) for protected services.

[TinyAuth]: https://tinyauth.app

### Portainer Stack (`portainer/`)

Container management UI. Use `bin/portainer-up.sh` in cron for GitOps:

```bash
# Cron example (every 5 minutes)
*/5 * * * * /path/to/bin/portainer-up.sh
```

### Public Stack (`public/`)

Core infrastructure and utility services.

- **caddy** — Reverse proxy, automatic HTTPS
- **duckdns** — Dynamic DNS
- **tinyauth** — OAuth forward auth
- **whoami** — Request echo (debugging)
- **httpbin** — HTTP testing
- **librespeed** — Speed test

### Docker Stack (`docker/`)

Monitoring and container maintenance.

- **autoheal** — Restart unhealthy containers
- **dozzle** — Real-time container log viewer
- **beszel** — Server monitoring hub
- **beszel_agent** — Monitoring agent (host network)

### Usenet Stack (`usenet/`)

Usenet streaming and indexing.

- **nzbhydra2** — NZB indexer search
- **nzbdav** — NZB WebDAV server
- **streamnzb** — Usenet streamer
- **usenetstreamer** — Stremio addon
