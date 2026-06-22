# AI Agent Instructions

Always review README.md and update it and AGENTS.md.
AGENTS.md should not repeat information that is already in README.md
and should include information relevant to agents only.

## Agent Workflows

### Pre-commit

Agents should ensure that pre-commit hooks are installed and run before
submitting changes.

- Install: `pre-commit install`
- Run on all files: `pre-commit run --all-files`

### CI & Linting

- **MegaLinter**: If MegaLinter fails in CI, check the `megalinter-reports/`
  directory (if available in artifacts) or logs for specific failures.
- **Renovate**: Be aware that Renovate is configured to automerge minor and
  digest updates.

### Conventions

- Commits should follow conventional commits style.
- Formatting is enforced via pre-commit hooks for YAML, Shell scripts (shfmt),
  and Markdown.

## Docker Stacks & Portainer

- For Docker Compose files (managed via Portainer):
  - Do not set `container_name`.
  - Use `expose` instead of `ports` for port configuration.
  - Avoid unnecessary quoting in `compose.yaml`; use double quotes only when
    strictly required (e.g., URLs with colons).
  - Every service must have a `healthcheck`. Specify only the `test` command,
    leaving `interval`, `timeout`, `retries` as defaults.
  - Prefer the service's built-in health check command when available
    (e.g., `redis-cli ping`, `pg_isready`, `/dozzle healthcheck`,
    `/beszel health`). Fall back to `curl -fsSL` or `wget -qO-` for
    HTTP checks.
  - Prefer `ghcr.io` over `docker.io` registry.
  - Use host bind mounts under `/apps/<service-name>/` instead of named
    volumes.
  - All stacks join the `caddy` external network for Caddy
    integration.
  - Caddy reverse proxy labels follow this pattern:

    ```yaml
    labels:
      caddy: "*.{$$DOMAIN}"
      caddy.import: reverse_proxy <service-name> <service-name>:<port>
    ```

  - Use `depends_on` with `condition: service_healthy` or
    `condition: service_started` when a service requires another to be ready.
  - Images must support `linux/arm64`. Prefer version tags if they are
    still maintained (release within 3 months compared to `latest` tag).
    Otherwise, use `latest` tag. Digests will be added by Renovate bot.

- Security hardening (apply to all services where possible):
  - Add `security_opt: [no-new-privileges:true]` to every service.
  - Add `cap_drop: [ALL]` and explicitly `cap_add` only required
    capabilities (e.g., `NET_BIND_SERVICE` for ports < 1024,
    `NET_ADMIN`/`NET_RAW` for VPN/firewall, `SYS_ADMIN` for FUSE).
  - Add `read_only: true` with `tmpfs: [/tmp]` (and `/var/run` if the
    service writes PID files). Mount writable paths as volumes.
  - Skip `cap_drop: ALL` and `read_only` for services that require
    complex privilege escalation (e.g., LinuxServer.io s6-overlay images,
    headless browsers, PostgreSQL).
  - Services with `network_mode: host` implicitly share the host UTS
    namespace; do not add redundant `uts: host`.

- Key ordering in compose files:
  - Top-level: `services`, `volumes`, `networks`, `secrets`, `configs`.
  - Service-level (grouped by concern):
    1. Identity: `image`, `build`, `pull_policy`, `platform`, `profiles`
    2. Execution: `entrypoint`, `command`, `working_dir`, `user`,
       `init`, `tty`, `stdin_open`
    3. Dependencies: `depends_on`, `extends`
    4. Configuration: `environment`, `env_file`, `secrets`, `configs`
    5. Runtime: `cap_add`, `cap_drop`, `security_opt`, `devices`,
       `privileged`, `read_only`, `shm_size`, `ulimits`, `gpus`,
       `group_add`, `sysctls`, `pid`, `ipc`, `uts`, `userns_mode`
    6. Storage: `volumes`, `tmpfs`
    7. Networking: `ports`, `expose`, `hostname`, `networks`,
       `network_mode`, `extra_hosts`, `dns`
    8. Lifecycle: `healthcheck`, `restart`, `deploy`,
       `stop_grace_period`, `stop_signal`, `post_start`, `pre_stop`
    9. Metadata: `labels`, `annotations`, `logging`
