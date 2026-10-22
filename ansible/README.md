# Ansible Playbook for zer0c00l.in

Deploys and configures the zer0c00l.in website with Nextcloud, including all
necessary services and security hardening.

## Quickstart

```bash
cd ansible

# Full deployment (fresh install or re-deploy)
ansible-playbook -i inventory.ini site.yml --ask-vault-pass

# Nextcloud-only redeploy / upgrade
ansible-playbook -i inventory.ini nextcloud.yml --ask-vault-pass

# Dry run (check mode) — see what would change without applying it
ansible-playbook -i inventory.ini site.yml --ask-vault-pass --check
```

You'll be prompted for the vault password. If you keep it in `.vault_pass`,
pass `--vault-password-file .vault_pass` instead of `--ask-vault-pass`.

## Supported playbooks

| Playbook | What it does | Use it for |
| --- | --- | --- |
| `site.yml` | Full deployment: static site, MariaDB, Nextcloud, fail2ban, Apache, certbot, validation. | Fresh install or a full re-deploy. |
| `nextcloud.yml` | Nextcloud only (re-extract + reconfigure + validate). | Routine Nextcloud version bumps without touching the rest of the stack. |
| `site.test.yml` | Same stack as `site.yml` but **skips `certbot` and `validate`** (they need a real domain / public internet). Generates a self-signed cert so the stack comes up in a container. | Testing against the local Docker target. |

All playbooks are **idempotent** — re-running only applies the changes that are
actually needed.

## Role execution order

`site.yml` runs the roles in this order:

1. **common** — base packages, PHP 8.4, static files
2. **mariadb** — database setup
3. **nextcloud** — Nextcloud installation
4. **fail2ban** — SSH + Nextcloud brute-force protection
5. **apache** — web server configuration
6. **certbot** — SSL certificate acquisition
7. **validate** — final reachability checks

> `nextcloud` runs before `fail2ban` so the Nextcloud log file exists for the
> nextcloud jail to validate against.

Each role has its own documentation under `roles/<role>/README.md`:

- [`common`](roles/common/README.md)
- [`mariadb`](roles/mariadb/README.md)
- [`nextcloud`](roles/nextcloud/README.md)
- [`fail2ban`](roles/fail2ban/README.md)
- [`apache`](roles/apache/README.md)
- [`certbot`](roles/certbot/README.md)
- [`validate`](roles/validate/README.md)

## Prerequisites

1. **Ansible** installed on the control machine (version 2.9 or later).
2. **SSH access** to the target server, with an SSH key configured in the
   inventory.
3. **Vault password** for decrypting encrypted variables.

## Vault

Sensitive variables live in `group_vars/all/vault.yml` (encrypted with Ansible
Vault). You need the vault password to decrypt them during execution.

Required vault-backed variables (the playbook fails without these):

- `nextcloud_password_salt`, `nextcloud_secret` — see
  [`roles/nextcloud/README.md`](roles/nextcloud/README.md)
- `nextcloud_db_password`
- `nextcloud_s3_access_key`, `nextcloud_s3_secret_key`

## Running the playbooks

### Basic execution

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

This prompts for the vault password, connects via SSH, runs all roles in
sequence, and validates that the site and Nextcloud are reachable.

### Using a vault password file

If the vault password is stored in `.vault_pass`:

```bash
ansible-playbook -i inventory.ini site.yml --vault-password-file .vault_pass
```

### Nextcloud-only redeploy / upgrade

```bash
ansible-playbook -i inventory.ini nextcloud.yml --ask-vault-pass
```

### Dry run (check mode)

See what would change without applying it:

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass --check
```

### Verbose output

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass -v    # or -vvv
```

> The roles do not define Ansible tags, so `--tags` cannot select individual
> roles. To re-run a single concern, use `nextcloud.yml` (Nextcloud) or re-run
> `site.yml` — it is idempotent.

### Running the Docker test stack

`site.test.yml` exercises the stack against a local Docker target (AlmaLinux 10
+ sshd), skipping `certbot` and `validate`. Run it from the control container:

```bash
docker run --rm --network zer0c00l-test \
  -v <repo>:/playbook -w /playbook/ansible \
  zer0c00l-control ansible-playbook -i inventory.docker.ini site.test.yml \
    --vault-password-file .vault_pass \
    -e ansible_host=zer0c00l-target -e ansible_port=22 \
    -e ansible_ssh_private_key_file=/playbook/ansible/.docker_test/test_key
```

## Configuration

- Role defaults: `roles/<role_name>/defaults/main.yml`
- Group variables: `group_vars/all/vault.yml` (requires vault password)
- Inventory-specific: `inventory.ini`

Key variables that may need adjustment: `certbot_domain`, `certbot_email`,
`nextcloud_version`, and the `fail2ban_*` parameters. See each role's README
for the full variable list.

## Security notes

- MariaDB listens only on localhost (127.0.0.1).
- fail2ban protects both SSH and Nextcloud from brute-force attacks.
- SSL/TLS is enforced with HSTS headers; HTTP is redirected to HTTPS.

## Maintenance

- **Updating Nextcloud** — bump `nextcloud_version` and re-run
  `nextcloud.yml`. Major version jumps require a backup + `nextcloud_reinstall`
  (see [`roles/nextcloud/README.md`](roles/nextcloud/README.md)).
- **Renewing certificates** — Let's Encrypt certs are renewed automatically by
  the `certbot-renew` timer. Manual: `certbot renew` on the target host.

## Support

- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Ansible Documentation](https://docs.ansible.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
