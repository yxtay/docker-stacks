# Systemd Timers

Replaces cron jobs with systemd user timer units for better
logging, missed-run recovery, and jitter support.

Uses a single template service (`run-script@.service`) that
runs any script from `bin/`. Only timer files need to be
added per job.

## Units

| Timer                    | Schedule    | Description                 |
|--------------------------|-------------|-----------------------------|
| `portainer-up.timer`     | Every 5 min | Ensure Portainer is running |
| `logrotate.timer`        | Hourly      | Custom log rotation         |
| `cleanup-symlinks.timer` | Daily       | Remove broken symlinks      |

## Adding a New Job

1. Place script in `bin/` (must be executable).
2. Create a `.timer` file with
  `Unit=run-script@<script-name>.service`.

## Install

```bash
../bin/systemd-setup.sh
```

This symlinks unit files to `~/.config/systemd/user/`,
enables timers, and sets up lingering.

## Verify

```bash
systemctl --user list-timers --all
journalctl --user -u run-script@portainer-up.sh
```
