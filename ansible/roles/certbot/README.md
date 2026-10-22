# Role: certbot

Obtains and renews Let's Encrypt SSL certificates.

## What it does

- Obtains a certificate for the domain using the Apache plugin.
- Enables the `certbot-renew` systemd timer for automatic renewal.
- Writes the certs to `/etc/letsencrypt/live/<domain>/`, which the `apache`
  vhost references.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `certbot_domain` | `zer0c00l.in` | Domain to obtain a cert for. |
| `certbot_email` | `admin@zer0c00l.in` | Let's Encrypt notification email. |
| `certbot_server_aliases` | `[]` | Additional names (e.g. www). |
| `certbot_staging` | `false` | Use the Let's Encrypt staging environment. |
| `certbot_redirect` | `false` | Enable automatic HTTP→HTTPS redirect. |
| `certbot_renew_timer` | `certbot-renew.timer` | Renewal timer unit name. |

## Notes

- Requires a real domain and public port 80 for the HTTP-01 challenge, so this
  role is **skipped in the Docker test environment** (`site.test.yml`), where a
  self-signed cert is generated instead.
- Manual renewal: `certbot renew` on the target host.
