# Role: validate

Final validation that the deployed stack is reachable over HTTPS.

## What it does

- Waits briefly for `httpd` to settle.
- Verifies `https://zer0c00l.in/` returns `200`.
- Verifies `https://zer0c00l.in/cloud/` returns `200` (following the redirect
  to `/cloud/index.php/login`).

## Notes

- Requires the site to be publicly reachable with a valid certificate, so this
  role is **skipped in the Docker test environment** (`site.test.yml`).
- The `nextcloud.yml` playbook also runs this role after redeploying
  Nextcloud.
