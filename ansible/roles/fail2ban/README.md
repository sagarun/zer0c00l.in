# Role: fail2ban

Brute-force protection for SSH and Nextcloud.

## What it does

- Installs and enables `fail2ban`.
- Configures a **sshd** jail (SSH brute-force protection).
- Configures a **nextcloud** jail that watches the Nextcloud log for
  failed logins.
- Defensively ensures the Nextcloud log file exists before the jail is
  validated (the jail fails to start if its `logpath` is missing).

## Ordering requirement

This role **must run after the `nextcloud` role**, so the Nextcloud log file
exists for the nextcloud jail to validate against. `site.yml` and
`site.test.yml` both order `nextcloud` before `fail2ban` for this reason.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `fail2ban_ssh_enabled` | `true` | Enable the sshd jail. |
| `fail2ban_ssh_maxretry` | `5` | Failed attempts before ban. |
| `fail2ban_ssh_bantime` | `3600` | Ban duration (seconds). |
| `fail2ban_ssh_findtime` | `600` | Window to count failures (seconds). |
| `fail2ban_nextcloud_enabled` | `true` | Enable the nextcloud jail. |
| `fail2ban_nextcloud_maxretry` | `3` | Failed attempts before ban. |
| `fail2ban_nextcloud_bantime` | `86400` | Ban duration (seconds). |
| `fail2ban_nextcloud_findtime` | `43200` | Window to count failures (seconds). |
| `fail2ban_nextcloud_logpath` | `/var/owncloud/data/nextcloud.log` | Log file to watch. |
| `fail2ban_nextcloud_ports` | `80,443` | Ports the jail applies to. |

## Monitoring

```bash
fail2ban-client status sshd
fail2ban-client status nextcloud
```
