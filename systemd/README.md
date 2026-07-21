# Systemd Timers

Replaces cron jobs with systemd user timer units for better
logging, missed-run recovery, and jitter support.

Uses a single template service (`run-script@.service`) that
runs any script from `bin/`. Only timer files need to be
added per job.

## Units

| Timer                    | Schedule    | Description               |
|--------------------------|-------------|---------------------------|
| `arcane-up.timer`        | Every 5 min | GitOps: sync Arcane stack |
| `logrotate.timer`        | Hourly      | Custom log rotation       |
| `cleanup-symlinks.timer` | Daily       | Remove broken symlinks    |

## Adding a New Job

1. Place script in `bin/` (must be executable).
2. Create a `.timer` file with
  `Unit=run-script@<script-name>.service`.

## Install

```bash
../bin/setup-systemd.sh
```

This symlinks unit files to `~/.config/systemd/user/`,
enables timers, and sets up lingering.

## Test Ad Hoc

```bash
# Run a service manually
systemctl --user start run-script@arcane-up.sh

# Trigger a timer immediately
systemctl --user start arcane-up.timer

# Check service status/result
systemctl --user status run-script@arcane-up.sh

# View logs
journalctl --user -u run-script@arcane-up.sh
```

## Verify

```bash
systemctl --user list-timers --all
```
