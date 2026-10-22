# Role: nextcloud

Installs and configures Nextcloud.

## What it does

- Detects the version already on disk (from `version.php`) and only
  downloads + extracts when it differs from the target, so re-runs are a no-op
  once the host is at the desired version.
- Extracts Nextcloud into `/var/www/html/nextcloud` and sets ownership to the
  `apache` user/group.
- Writes `config.php` (database, S3 primary storage, trusted domains,
  `overwritehost`, etc.).
- Fails fast if the required session-signing secrets are missing (see below).

## Required vault variables

The role **fails immediately** if these are not set, because they sign
Nextcloud sessions and tokens:

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

Other vault-backed variables this role expects:
`nextcloud_db_password`, `nextcloud_s3_access_key`, and
`nextcloud_s3_secret_key`.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `nextcloud_version` | `35.0.2` | Target version. Bump on each security release. |
| `nextcloud_download_url` | derived from version | Release tarball URL. |
| `nextcloud_reinstall` | `false` | `true` wipes and re-extracts (major version changes). |
| `nextcloud_web_root` | `/var/www/html` | Web root. |
| `nextcloud_install_dir` | `/var/www/html/nextcloud` | Install directory. |
| `nextcloud_http_user` / `nextcloud_http_group` | `apache` | Ownership user/group. |
| `nextcloud_db_name` / `nextcloud_db_user` / `nextcloud_db_host` | `nextcloud` / `nextcloud` / `localhost` | DB connection (password from vault). |
| `nextcloud_s3_bucket` | `nextcloud.zer0c00l.in` | S3 primary storage bucket. |
| `nextcloud_s3_region` | `us-west-1` | S3 region. |
| `nextcloud_s3_hostname` | `s3.us-west-1.amazonaws.com` | S3 endpoint. |
| `nextcloud_s3_port` | `443` | S3 port. |
| `nextcloud_s3_use_ssl` | `true` | Use TLS for S3. |
| `nextcloud_s3_use_path_style` | `false` | Path-style S3 URLs. |
| `nextcloud_s3_autocreate` | `true` | Auto-create bucket. |
| `nextcloud_trusted_domains` | `[zer0c00l.in]` | Hosts Nextcloud accepts. |
| `nextcloud_overwrite_host` | `zer0c00l.in` | Canonical host for absolute URLs. |

## Updating Nextcloud

Bump `nextcloud_version` in `defaults/main.yml` and re-run the
Nextcloud-only playbook:

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
> Bumping the code version here does **not** run `occ upgrade` (DB schema
> migration). See the comments in `defaults/main.yml` for details.

## Known gotcha (fixed 2026-08-24)

Version detection originally used `regex_replace(..., '\\1')`. In a YAML
single-quoted scalar `'\\1'` is the literal 3-char string `\\1`, so `re.sub`
replaced the match with literal `\1` text instead of the captured group — the
"installed version" fact became the whole raw `version.php` and never matched
the target, forcing a 280 MB re-download every run. Fixed by using
`regex_findall("OC_VersionString = '([^']+)'") | first | default('')`
(no backreference). See `tasks/main.yml`.
