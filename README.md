# docker-stacks

Automations with docker stacks

## OCI Resource Manager

The [`oci-rm/`](oci-rm/) directory contains a Terraform stack for OCI Resource
Manager that provisions an ARM Always Free VPS. See
[`oci-rm/README.md`](oci-rm/README.md) for setup and usage.

## Ansible Provisioning

The [`ansible/`](ansible/) directory provisions and hardens Docker hosts across
Proxmox LXC and OCI VPS targets. See [`ansible/README.md`](ansible/README.md)
for setup and usage.

## Docker Stacks

All stacks join the `caddy` external network and use Caddy for reverse proxy
with automatic HTTPS via DuckDNS. Services are exposed via wildcard subdomains
(`*.DOMAIN`). [TinyAuth] provides forward authentication via OAuth
(GitHub/Google) for protected services.

[TinyAuth]: https://tinyauth.app

### Portainer Stack (`portainer/`)

Container management UI. Use `bin/portainer-up.sh` in cron for GitOps:

```bash
# Cron example (every 5 minutes)
*/5 * * * * /path/to/bin/portainer-up.sh
```

### Infra Stack (`infra/`)

Core infrastructure and utility services.

- **caddy** — Reverse proxy, automatic HTTPS
- **tinyauth** — OAuth forward auth
- **socket_proxy** — Docker socket proxy
- **tailscale** — Mesh VPN
- **whoami** — Request echo (debugging)
- **librespeed** — Speed test

### DDNS Stack (`ddns/`)

Dynamic DNS updates.

- **duckdns** — DuckDNS dynamic DNS client

### Monitoring Stack (`monitoring/`)

Monitoring and container maintenance.

- **autoheal** — Restart unhealthy containers
- **dozzle** — Real-time container log viewer
- **beszel** — Server monitoring hub
- **beszel_agent** — Monitoring agent (host network)

### Usenet Stack (`usenet/`)

Usenet streaming and indexing.

- **nzbhydra2** — NZB indexer search
- **nzbdav** — NZB WebDAV server
- **usenetstreamer** — Stremio addon
- **streamnzb** — Usenet streamer
- **altmount** — Usenet WebDAV mount
- **radarr_usenet** — Movie manager (Usenet)
- **sonarr_usenet** — TV show manager (Usenet)

### Torrent Stack (`torrent/`)

Torrent streaming and indexing.

- **prowlarr** — Indexer manager (Usenet + Torrents)
- **rclone** — Debrid FUSE mount
- **rdtclient** — Real-Debrid download client
- **radarr_torrent** — Movie manager (Torrents)
- **sonarr_torrent** — TV show manager (Torrents)
- **profilarr** — ARR profile manager

### Backup Stack (`backup/`)

Daily backups of `/apps` to Google Drive using restic with rclone backend.
Retention: 7 daily, 4 weekly, 3 monthly snapshots.

- **resticprofile** — Scheduled restic backups via crond
  with Google Drive (rclone) backend
