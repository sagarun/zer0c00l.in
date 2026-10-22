# Role: common

Base system setup. Runs first in the stack and provides the packages and
runtime that every other role depends on.

## What it does

- Installs the **EPEL** and **Remi** repositories (EL10) and imports their GPG keys.
- Enables and installs the **PHP 8.4** module stream (`php:remi-8.4`).
- Installs the required packages: `httpd`, `mariadb-server`, `certbot`,
  `python3-certbot-apache`, and the `php84-php-*` extensions Nextcloud needs
  (gd, mbstring, mysqlnd, opcache, pdo, imagick, zip, process, sodium, xml, ...).
- Serves Nextcloud via **php-fpm** (not mod_php): removes `php84-php` so the
  Remi conf falls back to the php-fpm handler, and points the php-fpm pool at
  the `apache` user/group.
- Hardens the PHP runtime:
  - `memory_limit = 512M`
  - `expose_php = Off`
  - php-fpm pool: `security.limit_extensions = .php .phar`,
    `request_terminate_timeout = 60`, `catch_workers_output = yes`,
    `clear_env = yes`
- Ensures `php84-php-fpm` is enabled and running.
- Creates the web root `/var/www/zer0c00l.in/public_html` and deploys the
  static site from `static/` into it.

## Variables

No defaults are defined (`defaults/main.yml` is empty). This role is driven
entirely by its tasks.

## Notes

- The static site's `<Directory>` uses `AllowOverride None`, so `static/.htaccess`
  headers are **not** read by Apache. The security headers actually served come
  from the Apache vhost (see the `apache` role).
- PHP-FPM is the PHP handler for the whole stack; the `apache` role wires the
  vhost to the php-fpm socket.
