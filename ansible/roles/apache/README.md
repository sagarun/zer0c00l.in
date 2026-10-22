# Role: apache

Configures the Apache (httpd) virtual host for zer0c00l.in.

## What it does

- Installs and enables `httpd`.
- Deploys the vhost template (`templates/zer0c00l.conf.j2`) to
  `/etc/httpd/conf.d/zer0c00l.in.conf`.
- Serves the static site from the web root and proxies `/cloud/` to Nextcloud
  via the **php-fpm** socket (not mod_php).
- Sets the served security headers (HSTS, X-Content-Type-Options,
  X-Frame-Options, Referrer-Policy, Permissions-Policy).
- Disables the `info`, `status`, and `userdir` modules.
- Ensures `httpd` is enabled and running.
- Opens the `http` and `https` services in **firewalld** (idempotent) so the
  site is reachable from the internet.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `apache_domain` | `zer0c00l.in` | Primary domain (ServerName). |
| `apache_document_root` | `/var/www/zer0c00l.in/public_html` | Static site root. |
| `apache_server_aliases` | `[]` | Extra ServerAlias entries. |
| `apache_php_fpm_socket` | `/var/opt/remi/php84/run/php-fpm/www.sock` | php-fpm socket to proxy to. |

## Notes

- The static site's `<Directory>` uses `AllowOverride None`, so
  `static/.htaccess` headers are **not** read. The vhost `Header always set ...`
  lines are what's actually served. To change served security headers, edit the
  vhost template + `/etc/httpd/conf.d/zer0c00l.in.conf`, then
  `apachectl graceful`.
- The vhost points at `/etc/letsencrypt/live/zer0c00l.in/*.pem`, which the
  `certbot` role populates. In the Docker test environment (`site.test.yml`) a
  self-signed cert is generated at those paths instead.
