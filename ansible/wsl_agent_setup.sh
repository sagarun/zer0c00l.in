#!/usr/bin/env bash
# Start (or reuse) an ssh-agent in WSL and persist its env for later invocations.
set -e
ENV_FILE="$HOME/.ssh/agent_env"

# Reuse an existing live agent if present
if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    . "$ENV_FILE"
    if ssh-add -l >/dev/null 2>&1 || [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        echo "REUSED existing agent: $SSH_AUTH_SOCK"
        ssh-add -l 2>&1 || true
        exit 0
    fi
fi

eval "$(ssh-agent -s)"
echo "export SSH_AUTH_SOCK=\"$SSH_AUTH_SOCK\"" > "$ENV_FILE"
echo "export SSH_AGENT_PID=\"$SSH_AGENT_PID\"" >> "$ENV_FILE"
chmod 600 "$ENV_FILE"
echo "STARTED new agent: $SSH_AUTH_SOCK (pid $SSH_AGENT_PID)"
ssh-add -l 2>&1 || true
