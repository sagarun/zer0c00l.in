#!/bin/sh
cd /playbook/ansible
ansible-vault view --vault-password-file .vault_pass group_vars/all/vault.yml 2>&1 | grep -oE '[a-z_]+:' | sort -u
