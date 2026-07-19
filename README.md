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

All stacks join the `proxy` external network and use Caddy for reverse proxy
with automatic HTTPS via DuckDNS. Services are exposed via wildcard subdomains
(`*.DOMAIN`). [TinyAuth] provides forward authentication via OAuth
(GitHub/Google) for protected services.

All services have deploy resource limits (1 CPU, 4 GB memory, 512 PIDs) for
isolation and stability.

[TinyAuth]: https://tinyauth.app

### Agents Stack (`agents/`)

Autonomous AI agent stack.

- **hermes** — Autonomous AI agent with persistent memory and tool use
- **socket-proxy** — Dedicated Docker socket proxy for hermes
  (untrusted code execution environment)

### Proxy Stack (`proxy/`)

Reverse proxy and authentication gateway.

- **caddy** — Reverse proxy, automatic HTTPS
- **tinyauth** — OAuth forward auth

Caddy supports optional per-deployment reverse proxy configs via
`/apps/caddy/extras/*.caddy` (glob import, safe when empty).

### Pangolin Stack (`pangolin/`)

Self-hosted tunneling and reverse proxy gateway with SSO.

- **pangolin** — Tunnel server and resource manager
- **gerbil** — WireGuard tunnel endpoint
- **traefik** — Reverse proxy (network mode via gerbil)

### Infra Stack (`infra/`)

Core infrastructure and utility services.

- **socket-proxy** — Docker socket proxy
- **tailscale** — Mesh VPN
- **whoami** — Request echo (debugging)
- **librespeed** — Speed test

### DDNS Stack (`ddns/`)

Dynamic DNS updates.

- **duckdns** — DuckDNS dynamic DNS client

### DNS Stack (`dns/`)

Network-wide DNS filtering.

- **adguard** — DNS server with ad/tracker blocking

### Security Stack (`security/`)

Intrusion detection and web application firewall.

- **crowdsec** — IDS/IPS with AppSec WAF (virtual patching, generic rules)

CrowdSec monitors Caddy access logs, syslog, and kernel logs. The AppSec
engine (port 7422) inspects HTTP requests via Caddy's `appsec_url` directive.
Acquisition configs live in `acquis.d/`.

### Monitoring Stack (`monitoring/`)

Monitoring and container maintenance.

- **autoheal** — Restart unhealthy containers
- **dozzle** — Real-time container log viewer
- **beszel** — Server monitoring hub
- **beszel-agent** — Monitoring agent (host network)

### Portainer Stack (`portainer/`)

Container management UI.

- **portainer** — Container management dashboard

### Dockhand Stack (`dockhand/`)

Container management UI.

- **dockhand** — Docker container management dashboard

### Sencho Stack (`sencho/`)

Compose stack editor.

- **sencho** — Docker Compose file editor UI

### Arcane Stack (`arcane/`)

Container management UI. GitOps via systemd timer (every 5 minutes).

- **arcane** — Docker container management dashboard

### Backup Stack (`backup/`)

Encrypted backups of `/apps` using restic with resticprofile orchestration.
Local repository copied to Google Drive via rclone backend.
Retention: 7 daily, 4 weekly, 3 monthly snapshots.
Failure notifications sent to ntfy.sh.
Also provides one-way sync of `/apps` to `/data/apps` for local redundancy.

- **resticprofile** — Scheduled restic backups via crond
- **rsync** — Archive copy with hardlinks, ACLs, xattrs to `/data/apps`
- **rclone** — Alternative one-way sync to `/data/apps`

### Network Stack (`network/`)

Network monitoring and device discovery.

- **netalertx** — Network device scanner and alerting (host network)

### Home Assistant Stack (`homeassistant/`)

Home automation and related services. All services use host networking for
mDNS/device discovery.

- **homeassistant** — Home automation platform
- **music-assistant** — Music streaming server (SMB mount support)
- **esphome** — ESP device firmware manager (OTA/USB flash)
- **trmnlha** — TRMNL e-ink display dashboard for HA

### Immich Stack (`immich/`)

Self-hosted photo and video management.

- **immich-server** — Main Immich server
- **immich-machine-learning** — ML inference (face detection, search)
- **redis** — Valkey cache
- **database** — PostgreSQL with pgvecto.rs
- **gphotos2immich** — Google Photos import bridge
- **immich-kiosk** — Photo slideshow display

### Usenet Stack (`usenet/`)

Usenet streaming and indexing.

- **nzbdavex** — Extended NZB WebDAV server
- **usenetstreamer** — Stremio addon
- **streamnzb** — Usenet streamer
- **altmount** — Usenet WebDAV mount
- **aiostreams** — Stremio super-addon

### Torrent Stack (`torrent/`)

Torrent streaming and indexing.

- **trawl** — Cloudflare/CAPTCHA bypass for scraping (FlareSolverr alternative)
- **prowlarr** — Indexer manager (Usenet + Torrents)
- **decypharr** — Debrid media gateway (qBittorrent API + WebDAV)
- **radarr** — Movie manager
- **sonarr** — TV show manager
- **profilarr** — ARR profile manager

## Systemd Timers

Scheduled tasks via systemd user timers (`systemd/`). Install with
`bin/setup-systemd.sh`.

| Timer              | Schedule    | Purpose                            |
| ------------------ | ----------- | ---------------------------------- |
| `arcane-up`        | Every 5 min | GitOps stack sync                  |
| `rsync-apps`       | Hourly      | Local /apps → /data/apps sync      |
| `logrotate`        | Hourly      | App log rotation                   |
| `cleanup-symlinks` | Daily       | Remove broken symlinks from mounts |

## Unison

Bidirectional file sync (`unison/`). Profiles:

- **apps.prf** — Local /apps ↔ /data/apps (prefers /apps)
- **homelab.prf** — Remote sync to primary server via SSH
