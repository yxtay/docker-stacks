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

Container management UI. GitOps via systemd timer (every 5 minutes).

### Dockhand Stack (`dockhand/`)

Container management UI.

- **dockhand** — Docker container management dashboard

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

### Backup Stack (`backup/`)

Encrypted backups of `/apps` using restic with resticprofile orchestration.
Local repository copied to Google Drive via rclone backend.
Retention: 7 daily, 4 weekly, 3 monthly snapshots.
Failure notifications sent to ntfy.sh.

- **resticprofile** — Scheduled restic backups via crond

### Sync Stack (`sync/`)

One-way sync of `/apps` to `/data/apps` for local redundancy using rsync.

- **rsync** — Archive copy with hardlinks, ACLs, xattrs

### Usenet Stack (`usenet/`)

Usenet streaming and indexing.

- **nzbhydra2** — NZB indexer search
- **nzbdav** — NZB WebDAV server
- **usenetstreamer** — Stremio addon
- **streamnzb** — Usenet streamer
- **altmount** — Usenet WebDAV mount

### Torrent Stack (`torrent/`)

Torrent streaming and indexing.

- **prowlarr** — Indexer manager (Usenet + Torrents)
- **rclone** — Debrid FUSE mount
- **rdtclient** — Real-Debrid download client
- **radarr** — Movie manager
- **sonarr** — TV show manager
- **profilarr** — ARR profile manager

### Home Assistant Stack (`homeassistant/`)

Home automation and related services. All services use host networking for
mDNS/device discovery.

- **homeassistant** — Home automation platform
- **music_assistant** — Music streaming server (SMB mount support)
- **esphome** — ESP device firmware manager (OTA/USB flash)
- **trmnl_ha** — TRMNL e-ink display dashboard for HA

### Immich Stack (`immich/`)

Self-hosted photo and video management.

- **immich_server** — Main Immich server
- **immich_machine_learning** — ML inference (face detection, search)
- **redis** — Valkey cache
- **database** — PostgreSQL with pgvecto.rs
- **gphotos2immich** — Google Photos import bridge
- **immich_kiosk** — Photo slideshow display

## Systemd Timers

Scheduled tasks via systemd user timers (`systemd/`). Install with
`bin/setup-systemd.sh`.

| Timer              | Schedule    | Purpose                            |
|--------------------|-------------|------------------------------------|
| `portainer-up`     | Every 5 min | GitOps stack sync                  |
| `rsync-apps`       | Hourly      | Local /apps → /data/apps sync      |
| `logrotate`        | Hourly      | App log rotation                   |
| `cleanup-symlinks` | Daily       | Remove broken symlinks from mounts |

## Unison

Bidirectional file sync (`unison/`). Profiles:

- **apps.prf** — Local /apps ↔ /data/apps (prefers /apps)
- **homelab.prf** — Remote sync to primary server via SSH
