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
  - Prefer `curl -fsSL` or `wget -qO-` for HTTP health checks. For
    non-HTTP services, use the service's native CLI (e.g., `redis-cli ping`,
    `pg_isready`).
  - Prefer `ghcr.io` over `docker.io` registry.
  - Use host bind mounts under `/apps/<service-name>/` instead of named
    volumes.
  - All stacks join the `public_default` external network for Caddy
    integration.
  - Caddy reverse proxy labels follow this pattern:

    ```yaml
    labels:
      caddy: "*.{$$DOMAIN}"
      caddy.import: reverse_proxy <service-name> <service-name>:<port>
    ```

  - Use `depends_on` with `condition: service_healthy` or
    `condition: service_started` when a service requires another to be ready.
- Key ordering in compose files:
  - Top-level: `services`, `volumes`, `networks`, `secrets`, `configs`.
  - Service-level (grouped by concern):
    1. Identity: `image`, `build`, `pull_policy`, `platform`, `profiles`
    2. Execution: `command`, `entrypoint`, `working_dir`, `user`
    3. Dependencies: `depends_on`, `extends`
    4. Configuration: `environment`, `env_file`, `secrets`, `configs`
    5. Storage: `volumes`, `tmpfs`
    6. Networking: `ports`, `expose`, `hostname`, `networks`,
        `network_mode`, `extra_hosts`, `dns`
    7. Lifecycle: `healthcheck`, `restart`, `deploy`,
        `stop_grace_period`, `stop_signal`
    8. Metadata: `labels`, `annotations`, `logging`

### Image Pinning & Architecture

- **ARM64 Compatibility**: When running on OCI Ampere A1 (ARM64), ensure all
  pinned images support the `linux/arm64` architecture.
- **Tagging Strategy**: Prefer specific semantic version tags (e.g., `v1.2.3`)
  over generic tags like `latest` or `lts`.
- **Renovate Compatibility**: Renovate is configured to keep these versioned
  tags updated. Avoid pinning via digests unless explicitly required, to keep
  configuration readable.
