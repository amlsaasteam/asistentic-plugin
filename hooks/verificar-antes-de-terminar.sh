#!/usr/bin/env bash
# Stop hook. Si hay cambios de código sin verificar, corre el comando de tests declarado en
# asistentic.yaml (verificacion.comando) y no deja terminar hasta que pase. Exit 2 = seguir trabajando.
# Evita bucles: si ya bloqueó una vez en este turno (stop_hook_active) o el diff no cambió desde la última verificación, deja pasar.
INPUT=$(cat)
ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
[ "$ACTIVE" = "true" ] && exit 0

[ -f asistentic.yaml ] || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Comando y timeout desde asistentic.yaml (sin depender de yq)
CMD=$(awk '/^verificacion:/{f=1;next} f&&/^[^ ]/{f=0} f&&/comando:/{sub(/.*comando:[ ]*/,"");sub(/[ ]*#.*/,"");print;exit}' asistentic.yaml)
TMO=$(awk '/^verificacion:/{f=1;next} f&&/^[^ ]/{f=0} f&&/timeout_segundos:/{sub(/.*timeout_segundos:[ ]*/,"");sub(/[ ]*#.*/,"");print;exit}' asistentic.yaml)
[ -z "$CMD" ] && exit 0
TMO=${TMO:-600}

# Solo si hay cambios en código (no docs ni yaml)
CAMBIOS=$(git status --porcelain -- . ':!docs' ':!*.md' ':!*.yaml' ':!*.yml' ':!.gitignore' ':!.asistentic' 2>/dev/null)
[ -z "$CAMBIOS" ] && exit 0

mkdir -p .asistentic
# Portable (GNU y BSD/macOS): sin sha256sum, timeout ni xargs -r.
hash_portable() { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi; }
HASH=$( (git diff; git diff --cached; git ls-files --others --exclude-standard | while IFS= read -r f; do [ -f "$f" ] && cat "$f"; done 2>/dev/null) | hash_portable | cut -c1-16)
[ -f .asistentic/ultima-verificacion ] && [ "$(cat .asistentic/ultima-verificacion)" = "$HASH" ] && exit 0

grep -qx '.asistentic/' .gitignore 2>/dev/null || echo '.asistentic/' >> .gitignore

if command -v timeout >/dev/null 2>&1; then
  SALIDA=$(timeout "$TMO" bash -c "$CMD" 2>&1); RC=$?
elif command -v gtimeout >/dev/null 2>&1; then
  SALIDA=$(gtimeout "$TMO" bash -c "$CMD" 2>&1); RC=$?
else
  # macOS sin coreutils: perl mata el grupo de procesos completo al vencer el tiempo (código 124, como timeout)
  SALIDA=$(perl -e 'my $t=shift; setpgrp(0,0); $SIG{ALRM}=sub{ kill "KILL", -getpgrp(); exit 124 }; alarm $t; my $rc=system(@ARGV); exit(($rc>>8)||($rc&127?128+($rc&127):0))' "$TMO" bash -c "$CMD" 2>&1); RC=$?
fi
if [ $RC -eq 0 ]; then
  echo "$HASH" > .asistentic/ultima-verificacion
  exit 0
fi

echo "Asistentic: hay cambios de código y la verificación ('$CMD') falló (código $RC). Corrige antes de dar por terminado y pega la salida en el PR. Últimas líneas:" >&2
echo "$SALIDA" | tail -30 >&2
exit 2
