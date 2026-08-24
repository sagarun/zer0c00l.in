#!/usr/bin/env bash
# Dry-run (check mode) of site.yml against zer0c00l.in.
# - Uses the WSL ssh-agent (key already added) for SSH auth.
# - Prompts for the vault password interactively (typed by the user, not the model).
set -u
. ~/.ssh/agent_env

cd /mnt/c/Users/Arun/work/zer0c00l.in/ansible

ANSIBLE="ansible-playbook"

# Ansible treats an executable vault-password file as a script to run, so copy
# the (executable) .vault_pass to a non-executable file and use that.
VAULT_PASS_FILE="/tmp/vault_pass"
cp /mnt/c/Users/Arun/work/zer0c00l.in/ansible/.vault_pass "$VAULT_PASS_FILE"
chmod 600 "$VAULT_PASS_FILE"

OUT="/mnt/c/Users/Arun/work/zer0c00l.in/ansible/dryrun.log"
echo "=== Running: $ANSIBLE -i inventory.ini site.yml --check --diff (log: $OUT) ==="
$ANSIBLE -i inventory.ini site.yml \
    --check \
    --diff \
    --vault-password-file "$VAULT_PASS_FILE" \
    -v > "$OUT" 2>&1
rc=$?
echo "=== ansible-playbook exit code: $rc ==="
echo "=== PLAY RECAP ==="
grep -A3 "PLAY RECAP" "$OUT"
exit $rc
