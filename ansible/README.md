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

## Running the Playbook

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

### Running Specific Roles

To run only specific roles, use tags (if configured) or limit execution:

```bash
# Run only the common role
ansible-playbook -i inventory.ini site.yml --ask-vault-pass --tags common

# Run only security-related roles
ansible-playbook -i inventory.ini site.yml --ask-vault-pass --tags fail2ban
```

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

To update Nextcloud, modify `nextcloud_version` in `roles/nextcloud/defaults/main.yml` and re-run the playbook.

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
