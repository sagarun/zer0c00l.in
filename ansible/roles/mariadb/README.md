# Role: mariadb

Sets up the MariaDB database that Nextcloud uses.

## What it does

- Ensures the `mariadb` service is enabled and running.
- Creates the Nextcloud database and a dedicated database user.
- Binds MariaDB to **localhost only** (127.0.0.1) — it is not exposed to the
  network.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `mariadb_service_name` | `mariadb` | Service name to manage. |
| `mariadb_unix_socket` | `/var/lib/mysql/mysql.sock` | Unix socket path. |
| `nextcloud_db_name` | `nextcloud` | Database name. |
| `nextcloud_db_user` | `nextcloud` | Database user. |
| `nextcloud_db_host` | `localhost` | Host Nextcloud connects from. |

## Required vault variables

- `nextcloud_db_password` — the database password. Must be provided via
  Ansible Vault (or `--extra-vars`); it is **not** set in defaults.
