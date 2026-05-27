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
