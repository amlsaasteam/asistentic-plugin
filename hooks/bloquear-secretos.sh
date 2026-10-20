#!/usr/bin/env bash
# Impide que el agente lea o edite archivos de secretos. Exit 2 = bloquear.
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE" ]; then exit 0; fi

BASENAME=$(basename "$FILE")
case "$BASENAME" in
  .env|.env.*|*.pfx|*.pem|*.key|appsettings.Production.json|secrets.json|credentials.json)
    echo "Asistentic: '$BASENAME' contiene secretos. Los agentes no los leen ni los editan; las credenciales viven en la bóveda." >&2
    exit 2
    ;;
esac
exit 0
