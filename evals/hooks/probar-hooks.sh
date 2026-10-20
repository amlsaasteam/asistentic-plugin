#!/usr/bin/env bash
# Pruebas deterministas de los hooks (no necesitan modelo). Uso: bash evals/hooks/probar-hooks.sh
# Sale con 1 si alguna falla. Correrlo en CI del repositorio del plugin.
cd "$(dirname "$0")/../.." || exit 1
H=hooks; FALLOS=0
espera() { # nombre, rc esperado, hook, json
  printf '%s' "$4" | bash "$H/$3" >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq "$2" ]; then echo "ok   $1"; else echo "FALLA $1 (esperado $2, obtuvo $rc)"; FALLOS=$((FALLOS+1)); fi
}
RAMA_PRINCIPAL="ma""in"; RAMA_VIEJA="mas""ter"   # partidas para que el hook del plugin no bloquee este archivo al editarlo
# push a la rama principal
espera "bloquea push a la rama principal"  2 bloquear-push-main.sh "{\"tool_input\":{\"command\":\"git push origin $RAMA_PRINCIPAL\"}}"
espera "bloquea push forzado a $RAMA_VIEJA" 2 bloquear-push-main.sh "{\"tool_input\":{\"command\":\"git push -f origin $RAMA_VIEJA\"}}"
espera "permite push a feature"            0 bloquear-push-main.sh '{"tool_input":{"command":"git push -u origin feature/LOT-123"}}'
# ticket en commit
espera "bloquea commit sin ticket"      2 exigir-ticket-en-commit.sh '{"tool_input":{"command":"git commit -m \"arreglos varios\""}}'
espera "permite commit con ticket"      0 exigir-ticket-en-commit.sh '{"tool_input":{"command":"git commit -m \"LOT-123: agregar validacion de monto\""}}'
espera "permite commit chore onboard"   0 exigir-ticket-en-commit.sh '{"tool_input":{"command":"git commit -m \"chore: onboard asistentic\""}}'
espera "bloquea commit -am sin ticket"  2 exigir-ticket-en-commit.sh "{\"tool_input\":{\"command\":\"git commit -am 'sin ticket'\"}}"
espera "permite commit -am con ticket"  0 exigir-ticket-en-commit.sh "{\"tool_input\":{\"command\":\"git commit -am 'LOT-7: ajustar'\"}}"
espera "bloquea --message sin ticket"   2 exigir-ticket-en-commit.sh '{"tool_input":{"command":"git commit --message=\"wip\""}}'
# archivos de secretos
espera "bloquea leer .env"              2 bloquear-secretos.sh '{"tool_input":{"file_path":"/repo/.env"}}'
espera "bloquea appsettings.Production" 2 bloquear-secretos.sh '{"tool_input":{"file_path":"src/Api/appsettings.Production.json"}}'
espera "permite appsettings.json"       0 bloquear-secretos.sh '{"tool_input":{"file_path":"src/Api/appsettings.json"}}'
# patrones en contenido
espera "bloquea cadena de conexion"     2 bloquear-patrones-peligrosos.sh '{"tool_input":{"file_path":"src/Db.cs","content":"\"Server=db1;Database=x;User Id=sa;Password=Secreto123;\""}}'
espera "bloquea uri mongo con clave"    2 bloquear-patrones-peligrosos.sh '{"tool_input":{"file_path":"src/a.js","new_string":"mongodb+srv://admin:pass123@cluster0.mongodb.net/db"}}'
espera "bloquea access key aws"         2 bloquear-patrones-peligrosos.sh '{"tool_input":{"file_path":"src/a.cs","content":"AKIAIOSFODNN7EXAMPLE"}}'
espera "bloquea sql concatenado"        2 bloquear-patrones-peligrosos.sh '{"tool_input":{"file_path":"src/Repo.cs","content":"\"SELECT * FROM ventas WHERE id = \" + id"}}'
espera "bloquea clave privada"          2 bloquear-patrones-peligrosos.sh '{"tool_input":{"file_path":"src/k.txt","content":"-----BEGIN RSA PRIVATE KEY-----"}}'
espera "bloquea host de produccion"     2 bloquear-patrones-peligrosos.sh '{"tool_input":{"file_path":"src/a.cs","content":"prod-db.cluster-abc.us-east-1.rds.amazonaws.com"}}'
espera "permite codigo parametrizado"   0 bloquear-patrones-peligrosos.sh '{"tool_input":{"file_path":"src/Repo.cs","content":"cmd.Parameters.AddWithValue(\"@id\", id); var pwd = config[\"Db:Password\"];"}}'
espera "permite patrones en reglas/"    0 bloquear-patrones-peligrosos.sh '{"tool_input":{"file_path":"reglas/x.md","content":"Password=abcd1234"}}'
# despliegue manual / produccion
espera "bloquea terraform apply"        2 bloquear-despliegue-manual.sh '{"tool_input":{"command":"terraform apply -auto-approve"}}'
espera "permite terraform plan"         0 bloquear-despliegue-manual.sh '{"tool_input":{"command":"terraform plan"}}'
espera "bloquea aws ecs update-service" 2 bloquear-despliegue-manual.sh '{"tool_input":{"command":"aws ecs update-service --cluster x --service api --force-new-deployment"}}'
espera "permite aws s3 ls"              0 bloquear-despliegue-manual.sh '{"tool_input":{"command":"aws s3 ls s3://reportes-qa"}}'
espera "bloquea kubectl apply"          2 bloquear-despliegue-manual.sh '{"tool_input":{"command":"kubectl apply -f k8s/"}}'
espera "bloquea workflow de prod"       2 bloquear-despliegue-manual.sh '{"tool_input":{"command":"gh workflow run cd.yml -f environment=prod"}}'
espera "permite workflow de ci"         0 bloquear-despliegue-manual.sh '{"tool_input":{"command":"gh workflow run ci.yml"}}'
espera "bloquea push de etiqueta"       2 bloquear-despliegue-manual.sh '{"tool_input":{"command":"git push origin v1.4.0"}}'
espera "bloquea sqlcmd a prod"          2 bloquear-despliegue-manual.sh '{"tool_input":{"command":"sqlcmd -S prod-sql.local -Q \"SELECT 1\""}}'
espera "permite sqlcmd a qa"            0 bloquear-despliegue-manual.sh '{"tool_input":{"command":"sqlcmd -S qa-sql.local -Q \"SELECT 1\""}}'
espera "bloquea perfil aws prod"        2 bloquear-despliegue-manual.sh '{"tool_input":{"command":"AWS_PROFILE=lotobet-prod aws s3 ls"}}'
espera "bloquea ssh a prod"             2 bloquear-despliegue-manual.sh '{"tool_input":{"command":"ssh deploy@prod-api-01"}}'
espera "permite grep production"        0 bloquear-despliegue-manual.sh '{"tool_input":{"command":"grep -rn production src/"}}'
# stop hook
T=$(mktemp -d); ( cd "$T" && git init -q && git config user.email a@b && git config user.name a && printf 'verificacion:\n  comando: bash test.sh\n' > asistentic.yaml && printf '#!/bin/bash\nexit ${FALLA:-0}\n' > test.sh && git add . && git commit -qm init )
HOOK="$PWD/$H/verificar-antes-de-terminar.sh"
chk() { if [ "$1" -eq "$2" ]; then echo "ok   $3"; else echo "FALLA $3 (esperado $2, obtuvo $1)"; FALLOS=$((FALLOS+1)); fi; }
( cd "$T" && echo '{}' | bash "$HOOK" >/dev/null 2>&1 ); chk $? 0 "stop: sin cambios deja terminar"
( cd "$T" && echo x > src.cs && echo '{}' | FALLA=1 bash "$HOOK" >/dev/null 2>&1 ); chk $? 2 "stop: tests fallan bloquea"
( cd "$T" && echo '{}' | bash "$HOOK" >/dev/null 2>&1 ); chk $? 0 "stop: tests pasan deja terminar"
( cd "$T" && echo '{}' | FALLA=1 bash "$HOOK" >/dev/null 2>&1 ); chk $? 0 "stop: mismo diff no repite la verificacion"
( cd "$T" && echo y >> src.cs && echo '{"stop_hook_active":true}' | FALLA=1 bash "$HOOK" >/dev/null 2>&1 ); chk $? 0 "stop: no entra en bucle"
rm -rf "$T"
echo; if [ $FALLOS -eq 0 ]; then echo "Todos los hooks pasan."; else echo "$FALLOS fallo(s)."; exit 1; fi
