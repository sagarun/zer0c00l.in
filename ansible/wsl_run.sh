#!/usr/bin/env bash
# ACTUAL run (apply mode) of site.yml against zer0c00l.in.
# - Uses the WSL ssh-agent (key already added) for SSH auth.
# - Reads the vault password from .vault_pass (same dir as this script).
#   The password is passed to ansible via --vault-password-file, so it is
#   never typed into the model or echoed to the terminal.
set -u
. ~/.ssh/agent_env

cd /mnt/c/Users/Arun/work/zer0c00l.in/ansible

ANSIBLE="ansible-playbook"

# Ansible treats an executable vault-password file as a script to run, so copy
# the (executable) .vault_pass to a non-executable file and use that.
VAULT_PASS_FILE="/tmp/vault_pass"
cp /mnt/c/Users/Arun/work/zer0c00l.in/ansible/.vault_pass "$VAULT_PASS_FILE"
chmod 600 "$VAULT_PASS_FILE"

OUT="/mnt/c/Users/Arun/work/zer0c00l.in/ansible/run.log"
echo "=== Running: $ANSIBLE -i inventory.ini site.yml (APPLY, log: $OUT) ==="
$ANSIBLE -i inventory.ini site.yml \
    --diff \
    --vault-password-file "$VAULT_PASS_FILE" \
    -v > "$OUT" 2>&1
rc=$?
# Clean up the temp vault password copy.
rm -f "$VAULT_PASS_FILE"
echo "=== ansible-playbook exit code: $rc ==="
echo "=== PLAY RECAP ==="
grep -A3 "PLAY RECAP" "$OUT"
exit $rc
