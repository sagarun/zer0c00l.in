# Ansible Playbook for zer0c00l.in

This Ansible playbook deploys and configures the zer0c00l.in website with Nextcloud, including all necessary services and security hardening.

## Overview

The playbook sets up:
- **Static website** deployment from `static/` directory
- **Nextcloud** installation and configuration
- **Apache** web server with SSL/TLS
- **MariaDB** database (bound to localhost only)
- **Let's Encrypt** SSL certificates
- **fail2ban** for SSH and Nextcloud brute-force protection
- **PHP 8.4** with required extensions

## Prerequisites

1. **Ansible** installed on your control machine (version 2.9 or later)
2. **SSH access** to the target server (zer0c00l.in)
3. **SSH key** configured (`~/.ssh/id_rsa_docean` as specified in inventory)
4. **Vault password** for decrypting encrypted variables

## Inventory

The inventory file (`inventory.ini`) is configured with:
- Host: `zer0c00l.in`
- SSH user: `root`
- SSH key: `~/.ssh/id_rsa_docean`

## Vault Configuration

Sensitive variables are stored in `group_vars/all/vault.yml` and encrypted with Ansible Vault. You'll need the vault password to decrypt these during playbook execution.

### Required Nextcloud secrets

The `nextcloud` role **fails immediately** if these two variables are not set, because they sign Nextcloud sessions and tokens. They must be present in the vault (or passed on the command line):

- `nextcloud_password_salt`
- `nextcloud_secret`

Generate both with:

```bash
openssl rand -base64 48
```

You can supply them via the vault, or directly on the command line:

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass \
  -e nextcloud_password_salt="$(openssl rand -base64 48)" \
  -e nextcloud_secret="$(openssl rand -base64 48)"
```

> **Warning:** if you regenerate these values on an existing install, all
> existing Nextcloud sessions and tokens are invalidated and users will be
> signed out. Only set them once (or change them deliberately).

Other vault-backed variables the roles expect: `nextcloud_db_password`,
`nextcloud_s3_access_key`, and `nextcloud_s3_secret_key`.

## Running the Playbook

### Running from WSL (Windows control machine)

The control machine is Windows, and Ansible runs inside **WSL**. The workflow
is:

1. **Start/reuse the ssh-agent** (once per session) so the key is loaded and
   its env is persisted to `~/.ssh/agent_env`:
   ```bash
   wsl -e bash -lc 'bash /mnt/c/Users/Arun/work/zer0c00l.in/ansible/wsl_agent_setup.sh'
   ```
2. **Run the playbook** (apply mode). `wsl_run.sh` sources `~/.ssh/agent_env`
   for SSH auth and reads the vault password from `.vault_pass` (same dir) via
   `--vault-password-file`, so the password is never typed or echoed:
   ```bash
   wsl -e bash -lc 'bash /mnt/c/Users/Arun/work/zer0c00l.in/ansible/wsl_run.sh'
   ```
   Output goes to `ansible/run.log`.
3. **Dry run** (check mode) is `wsl_dryrun.sh` → `ansible/dryrun.log`.

**Script layout** (kept in `ansible/`):
- `wsl_run.sh` — the actual apply run (this is the one to use).
- `wsl_dryrun.sh` — check-mode (`--check --diff`) variant.
- `wsl_agent_setup.sh` — **prerequisite**: creates `~/.ssh/agent_env` that the
  above scripts source. Do not delete.

One-off helper scripts (port tests, ssh auth checks, version lookups, etc.)
live in `ansible/.test_scripts/` and are git-ignored. They are not part of the
run workflow. This also includes `run_ansible.py`, a Windows-side shim that
patches `os.get_blocking` (a Python 3.15+ API) and forces a UTF-8 locale so
`ansible-playbook` runs under the local Python 3.10 venv + ansible 10.7.0. It
is only needed if you run Ansible natively on Windows; the WSL workflow above
does not use it.

> **Gotcha (learned 2026-08-24):** the `nextcloud` role's version detection
> originally used `regex_replace(..., '\\1')`. In a YAML single-quoted scalar
> `'\\1'` is the literal 3-char string `\\1`, so `re.sub` replaced the match
> with literal `\1` text instead of the captured group — the "installed
> version" fact became the whole raw `version.php` and never matched the
> target, forcing a 280 MB re-download every run. Fixed by using
> `regex_findall("OC_VersionString = '([^']+)'") | first | default('')`
> (no backreference). See `roles/nextcloud/tasks/main.yml`.

### Basic Execution

Run the playbook with:

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

This will:
1. Prompt you for the vault password
2. Connect to zer0c00l.in via SSH
3. Execute all roles in sequence
4. Validate that the site and Nextcloud are accessible

### Using Vault Password File

If you have the vault password stored in `.vault_pass`:

```bash
ansible-playbook -i inventory.ini site.yml --vault-password-file .vault_pass
```

### Running a Subset of the Deployment

There are two playbooks:

- **`site.yml`** — the full deployment: static site, fail2ban, MariaDB,
  Nextcloud, Apache, certbot, and validation. Use this for a fresh install or
  a full re-deploy.
- **`nextcloud.yml`** — Nextcloud only (re-extract + reconfigure + validate).
  Use this for routine Nextcloud version bumps without touching the rest of
  the stack.

```bash
# Full deployment (all roles)
ansible-playbook -i inventory.ini site.yml --ask-vault-pass

# Nextcloud-only redeploy / upgrade
ansible-playbook -i inventory.ini nextcloud.yml --ask-vault-pass
```

> Note: the roles in this project do not define Ansible tags, so `--tags`
> cannot be used to select individual roles. To re-run a single concern, use
> `nextcloud.yml` (Nextcloud) or re-run `site.yml` — it is idempotent, so
> re-running it only applies the changes that are actually needed.

### Dry Run (Check Mode)

To see what changes would be made without actually applying them:

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass --check
```

### Verbose Output

For detailed output during execution:

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass -v
# or for even more detail:
ansible-playbook -i inventory.ini site.yml --ask-vault-pass -vvv
```

## Role Execution Order

The playbook executes roles in this order:

1. **common** - Base packages, PHP 8.4, static files
2. **fail2ban** - Security hardening
3. **mariadb** - Database setup
4. **nextcloud** - Nextcloud installation
5. **apache** - Web server configuration
6. **certbot** - SSL certificate acquisition
7. **validate** - Final validation checks

## Configuration

### Customizing Variables

- Role defaults: Edit files in `roles/<role_name>/defaults/main.yml`
- Group variables: Edit `group_vars/all/vault.yml` (requires vault password)
- Inventory-specific: Edit `inventory.ini`

### Important Variables

Key variables that may need adjustment:
- `certbot_domain`: Domain name for SSL certificate
- `certbot_email`: Email for Let's Encrypt notifications
- `nextcloud_version`: Nextcloud version to install
- `fail2ban_*`: fail2ban configuration parameters

Required (vault-backed) variables — the playbook fails without these:
- `nextcloud_password_salt`, `nextcloud_secret` (see [Required Nextcloud secrets](#required-nextcloud-secrets))
- `nextcloud_db_password`
- `nextcloud_s3_access_key`, `nextcloud_s3_secret_key`

## Troubleshooting

### Connection Issues

If SSH connection fails:
- Verify SSH key path in `inventory.ini`
- Test SSH connection manually: `ssh -i ~/.ssh/id_rsa_docean root@zer0c00l.in`
- Check firewall rules allow SSH access

### Vault Password Issues

If vault decryption fails:
- Ensure you're using the correct vault password
- Verify `group_vars/all/vault.yml` is properly encrypted
- Try re-encrypting: `ansible-vault encrypt group_vars/all/vault.yml`

### "nextcloud_password_salt and nextcloud_secret must be set"

The `nextcloud` role fails fast when these secrets are missing. Provide them via
the vault or on the command line (see [Required Nextcloud secrets](#required-nextcloud-secrets)):

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass \
  -e nextcloud_password_salt="$(openssl rand -base64 48)" \
  -e nextcloud_secret="$(openssl rand -base64 48)"
```

### Certificate Issues

If Let's Encrypt certificate acquisition fails:
- Ensure DNS is properly configured for the domain
- Verify port 80 is accessible (required for HTTP-01 challenge)
- Check rate limits if testing repeatedly

## Post-Deployment

After successful deployment:

1. **Verify services** are running:
   ```bash
   ssh -i ~/.ssh/id_rsa_docean root@zer0c00l.in
   systemctl status httpd mariadb php84-php-fpm fail2ban
   ```

2. **Check Nextcloud** is accessible:
   - Visit `https://zer0c00l.in/cloud/`
   - Complete the Nextcloud setup wizard

3. **Monitor fail2ban**:
   ```bash
   fail2ban-client status sshd
   fail2ban-client status nextcloud
   ```

## Security Notes

- MariaDB is configured to listen only on localhost (127.0.0.1)
- fail2ban protects both SSH and Nextcloud from brute-force attacks
- SSL/TLS is enforced with HSTS headers
- All traffic is redirected from HTTP to HTTPS

## Maintenance

### Updating Nextcloud

To update Nextcloud, bump `nextcloud_version` in
`roles/nextcloud/defaults/main.yml` and re-run the Nextcloud-only playbook:

```bash
ansible-playbook -i inventory.ini nextcloud.yml --ask-vault-pass
```

> **Major version jumps (e.g. 23 → 31) are not in-place upgrades.** Before
> re-running with a new major version you must:
> 1. Back up the database (`mysqldump`) and the data directory / S3 bucket.
> 2. Set `nextcloud_reinstall: true` so the old tree is removed.
> 3. Restore the database and re-point `datadirectory`, or migrate via the
>    official Nextcloud upgrade path.
>
> See the comments in `roles/nextcloud/defaults/main.yml` for details.

### Renewing Certificates

Let's Encrypt certificates are automatically renewed by certbot. Manual renewal:

```bash
ssh -i ~/.ssh/id_rsa_docean root@zer0c00l.in
certbot renew
```

## CI/CD with GitHub Actions

This repository includes a GitHub Actions workflow (`.github/workflows/ansible.yml`) that automatically validates and can deploy your Ansible playbook.

### Setup GitHub Secrets

To use the GitHub Actions workflow, you need to configure the following secrets in your GitHub repository:

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:

   - **`VAULT_PASSWORD`**: Your Ansible vault password
   - **`SSH_PRIVATE_KEY`**: Contents of your SSH private key (`~/.ssh/id_rsa_docean`)

### Workflow Jobs

The workflow includes three jobs:

1. **validate** - Runs on every push/PR:
   - Syntax checks the playbook
   - Lints the Ansible code
   - Validates the inventory

2. **dry-run** - Runs on pull requests:
   - Executes the playbook in check mode (`--check --diff`)
   - Shows what changes would be made without applying them

3. **deploy** - Runs only on pushes to `main`/`master`:
   - Actually deploys to production
   - Requires manual approval if environment protection is enabled
   - Runs validation after deployment

### Manual Trigger

You can manually trigger the workflow from the GitHub Actions tab → "Ansible Playbook CI/CD" → "Run workflow".

### Security Notes

- The `deploy` job uses the `production` environment, which can be configured to require manual approval
- SSH keys and vault passwords are stored as encrypted secrets
- The workflow only deploys on pushes to the main branch

## Support

For issues or questions, refer to:
- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Ansible Documentation](https://docs.ansible.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
