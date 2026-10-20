#!/usr/bin/env bash
# Exige que cada commit empiece con un ID de ticket tipo ABC-123, o con 'chore:' para tareas de plataforma (onboarding, CLAUDE.md). Exit 2 = bloquear.
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Portable (GNU y BSD/macOS): sin \s ni \b, que sed de macOS no entiende.
if echo "$CMD" | grep -Eq 'git[[:space:]]+commit([[:space:]]|$)'; then
  # Acepta -m "x", -am "x", -m="x", --message="x", --message "x"
  MSG=$(echo "$CMD" | grep -oE -- '(-[a-zA-Z]*m|--message)(=|[[:space:]]+)["'"'"'][^"'"'"']*' | head -1 | sed -E 's/^(-[a-zA-Z]*m|--message)(=|[[:space:]]+)["'"'"']//')
  if [ -n "$MSG" ] && ! echo "$MSG" | grep -Eq '^([A-Z][A-Z0-9]+-[0-9]+|chore):'; then
    echo "Asistentic: el mensaje de commit debe empezar con el ticket, por ejemplo 'LOT-123: agrega validación de monto' (o 'chore:' solo para tareas de plataforma)." >&2
    exit 2
  fi
fi
exit 0
