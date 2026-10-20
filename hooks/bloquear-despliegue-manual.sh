#!/usr/bin/env bash
# PreToolUse Bash. Un agente nunca despliega ni toca producción a mano: todo pasa por el pipeline.
# Bloquea comandos de despliegue directo y cualquier comando que apunte a producción. Exit 2 = bloquear.
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

bloquear() { echo "Asistentic: bloqueado. $1 Los despliegues y cambios en producción pasan por el pipeline (cd.yml) con aprobación humana; usa /asistentic:release o /asistentic:rollback." >&2; exit 2; }

# 1) Comandos de despliegue/infra que nunca corre un agente, apunten a donde apunten
if echo "$CMD" | grep -qiE '(^|[;&|[:space:]])(terraform|tofu)[[:space:]]+(apply|destroy)\b'; then bloquear "'terraform apply/destroy' se ejecuta desde el pipeline con plan revisado."; fi
if echo "$CMD" | grep -qiE '(^|[;&|[:space:]])(cdk[[:space:]]+(deploy|destroy)|sam[[:space:]]+deploy|serverless[[:space:]]+deploy|sls[[:space:]]+deploy|eb[[:space:]]+deploy|copilot[[:space:]]+(deploy|svc deploy))\b'; then bloquear "Despliegue directo detectado."; fi
if echo "$CMD" | grep -qiE '(^|[;&|[:space:]])aws[[:space:]]+(ecs[[:space:]]+update-service|lambda[[:space:]]+update-function-code|cloudformation[[:space:]]+(deploy|create-stack|update-stack|delete-stack)|elasticbeanstalk[[:space:]]+(create|update)-environment|s3[[:space:]]+(sync|cp)[^|]*--delete|rds[[:space:]]+(modify|delete|reboot)-db)'; then bloquear "Cambio de infraestructura o despliegue con la CLI de AWS."; fi
if echo "$CMD" | grep -qiE '(^|[;&|[:space:]])(kubectl|helm)[[:space:]]+(apply|delete|rollout|upgrade|install|uninstall|scale|set[[:space:]]+image)\b'; then bloquear "Cambio en Kubernetes con kubectl/helm."; fi
if echo "$CMD" | grep -qiE '(^|[;&|[:space:]])gh[[:space:]]+workflow[[:space:]]+run\b.*(prod|produccion|production|release|deploy)'; then bloquear "Lanzar un workflow de despliegue lo hace una persona desde GitHub."; fi
if echo "$CMD" | grep -qiE '(^|[;&|[:space:]])git[[:space:]]+push\b.*(--tags|refs/tags/|[[:space:]]v[0-9]+\.[0-9]+)'; then bloquear "Las etiquetas de release las crea el pipeline al fusionar el PR de release."; fi

# 2) Cualquier comando que mencione producción con herramientas de base de datos, ssh o perfiles de nube
if echo "$CMD" | grep -qiE '\b(prod|produccion|production|prd)\b'; then
  if echo "$CMD" | grep -qiE '(^|[;&|[:space:]])(sqlcmd|psql|mysql|mongosh|mongo|sqlplus|ssh|scp|rsync|aws|kubectl|helm|dotnet[[:space:]]+(publish|ef)|flyway|liquibase|dbup|migrate-mongo)\b'; then
    bloquear "Comando contra un ambiente de producción."
  fi
fi
if echo "$CMD" | grep -qiE -- '--profile[= ]+[a-z0-9_-]*(prod|prd)|AWS_PROFILE=[a-z0-9_-]*(prod|prd)|--context[= ]+[a-z0-9_-]*(prod|prd)|(prod|produccion|production)[-_.]?(db|sql|rds|cluster)[a-z0-9.-]*\.(amazonaws\.com|rds\.)'; then
  bloquear "Perfil, contexto o host de producción."
fi
exit 0
