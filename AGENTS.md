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

## Infrastructure Initialization

- **Cloud-init**: The instance initialization is handled via
  `oci-rm/templates/cloud-init.yaml`.
- **Terraform Fallback**: `oci-rm/compute.tf` is configured to automatically
  use the `cloud-init.yaml` template if the `user_data` variable is left
  empty.
- **Networking**: `iptables` is used for port management instead of `ufw` to
  ensure compatibility with Docker networking.

### Usenet Stack

- When modifying `usernet/compose.yaml`, ensure checkov skip annotations
  (`# checkov:skip=...`) are preserved or updated if necessary, as the stack
  is optimized for Dokploy and might trigger false positives for standard
  security checks.
- For Docker Compose files (especially for Dokploy):
  - Do not set `container_name`.
  - Use `expose` instead of `ports` for port configuration.
  - Use `networks: default: name: dokploy-network: external: true` to avoid
    setting networks per service.
  - Avoid unnecessary quoting in `compose.yaml`; use double quotes only when
    strictly required (e.g., URLs with colons).
  - Health checks should specify only the `test` command, leaving other options
    as default.
  - Use `curl -fsSL` or `wget -qO-` for health check commands where
    appropriate.
