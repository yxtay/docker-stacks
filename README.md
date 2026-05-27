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
