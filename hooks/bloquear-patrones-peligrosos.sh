#!/usr/bin/env bash
# PreToolUse Write|Edit|MultiEdit. Revisa el CONTENIDO que el agente va a escribir
# (no solo el nombre del archivo) y bloquea secretos y patrones inseguros. Exit 2 = bloquear.
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // (.tool_input.edits // [] | map(.new_string) | join("\n")) // empty')

[ -z "$CONTENT" ] && exit 0

# Archivos donde los patrones son esperables (reglas, docs del plugin, tests de los hooks)
case "$FILE" in
  */reglas/*|*/evals/*|*/hooks/*|*.md) exit 0 ;;
esac

# Patrón ~~ mensaje  (grep -E, sin distinguir mayúsculas)
PATRONES=(
  'password\s*=\s*["'"'"'][^"'"'"']{4,}~~Credenciales en texto plano (password=...)'
  'pwd\s*=\s*[^;"'"'"' ]{4,};~~Cadena de conexión con contraseña (Pwd=...)'
  '(server|data source|host)\s*=\s*[^;"'"'"']+;.*(password|pwd)\s*=~~Cadena de conexión completa con credenciales'
  'mongodb(\+srv)?://[^/@"'"'"' ]+:[^/@"'"'"' ]+@~~URI de MongoDB con usuario y contraseña'
  'jdbc:[a-z]+://[^"'"'"' ]+(password|pwd)=~~JDBC con contraseña embebida'
  'AKIA[0-9A-Z]{16}~~Access key de AWS'
  'aws_secret_access_key\s*=~~Secret key de AWS'
  'sk-ant-[a-z0-9-]{20,}~~API key de Anthropic'
  'ghp_[A-Za-z0-9]{30,}~~Token de GitHub'
  '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----~~Clave privada'
  'eyJ[A-Za-z0-9_-]{20,}\.eyJ[A-Za-z0-9_-]{20,}\.~~JWT embebido'
  '(bearer|authorization:)\s+["'"'"']?[A-Za-z0-9._-]{30,}~~Token de autorización embebido'
  '(select|insert|update|delete)\b[^;]*["'"'"']\s*\+\s*[a-z_]+~~SQL concatenado con variables (usa parámetros)'
  '\$where\s*:~~Operador $where de MongoDB (inyección)'
  'with\s*\(\s*nolock\s*\)~~NOLOCK (solo en reportes de solo lectura con justificación)'
  'appsettings\.production~~Referencia a configuración de producción'
  '(prod|produccion|production)[-_.]?(db|sql|rds|cluster)[a-z0-9.-]*\.(amazonaws\.com|rds\.|local)~~Host de base de datos de producción'
)

for entrada in "${PATRONES[@]}"; do
  regex="${entrada%%~~*}"
  msg="${entrada#*~~}"
  if echo "$CONTENT" | grep -qiE -e "$regex"; then
    echo "Asistentic: bloqueado. $msg en ${FILE:-el contenido}. Las credenciales van en la bóveda y las consultas se parametrizan. Si es un falso positivo, explica por qué y pide al usuario que lo escriba a mano." >&2
    exit 2
  fi
done
exit 0
