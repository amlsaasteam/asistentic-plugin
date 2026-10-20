#!/usr/bin/env bash
# Bloquea git push directo a main o master. Exit 2 = bloquear.
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -Eq 'git\s+push\b.*\b(origin\s+)?(main|master)\b'; then
  echo "Asistentic: no se hace push directo a main/master. Trabaja en una rama feature/JIRA-123 y abre un PR." >&2
  exit 2
fi
if echo "$CMD" | grep -Eq 'git\s+push\b.*--force'; then
  echo "Asistentic: push --force bloqueado. Si de verdad hace falta, lo hace una persona desde su terminal." >&2
  exit 2
fi
exit 0
