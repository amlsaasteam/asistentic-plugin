# Plugin Asistentic (v0.1, piloto)

Ciclo de desarrollo Asistentic para Claude Code: comandos, agentes, hooks y reglas por stack.

## Qué contiene

| Carpeta | Qué hay |
|---|---|
| `skills/` | Ciclo completo: `onboard-repo`, `pipeline`, `metricas`, `spec`, `tareas`, `implementar`, `desarrollar`, `revisar`, `validar-qa`, `release`, `verificar-release`, `rollback`, `fix`, `postmortem`, `revisar-claude-md`, `ayuda` |
| `agents/` | Construir: `desarrollador`, `devops`. Revisar: `revisor-codigo` (umbral de confianza 80), `validador-sql` (SQL Server, Oracle, Aurora PostgreSQL/MySQL), `validador-mongodb`, `cazador-fallos-silenciosos`, `analista-tests` |
| `hooks/` | Bloqueo de push a la rama principal, ticket obligatorio en commits, bloqueo de archivos de secretos, bloqueo de secretos y patrones peligrosos en el contenido escrito, bloqueo de despliegues manuales y comandos contra producción, verificación (tests) antes de terminar una tarea con cambios |
| `evals/` | Pruebas de los hooks (`bash evals/hooks/probar-hooks.sh`) y casos para `claude plugin eval` |
| `reglas/` | `desarrollo.md` (mejores prácticas generales), `devops.md` (pipeline, ambientes, despliegue, rollback, observabilidad), por stack (`dotnet.md`, `java.md`) y por motor de datos (`sqlserver.md`, `oracle.md`, `aurora.md`, `mongodb.md`) |

## Probarlo en un repositorio

```bash
# 1. Validar el plugin
claude plugin validate ./asistentic-plugin

# 2. Dar permisos a los hooks (una vez)
chmod +x asistentic-plugin/hooks/*.sh

# 3. Abrir Claude Code en el repositorio piloto con el plugin cargado
cd /ruta/al/repo-piloto
claude --plugin-dir /ruta/a/asistentic-plugin

# 4. Dentro de Claude Code
/asistentic:ayuda
/asistentic:onboard-repo
```

Requiere `jq` instalado para los hooks (`brew install jq` o `apt install jq`). El hook de verificación lee `verificacion.comando` de `asistentic.yaml` en cada repositorio; sin esa clave no hace nada.

## Cómo se extiende

- Una regla nueva: edita el archivo de `reglas/` que corresponda y abre un PR a este repositorio.
- Un comando nuevo: carpeta en `skills/<nombre>/SKILL.md`.
- Después de editar, dentro de la sesión: `/reload-plugins`.
- Antes de abrir el PR al plugin: `bash evals/hooks/probar-hooks.sh` (segundos) y, si cambiaste un skill o agente, `claude plugin eval . --scaffold --trust-plugin --runs 1` (ver `evals/README.md`).
- Instalar desde el marketplace: `/plugin install asistentic --marketplace <owner>/asistentic-plugin` (ajusta `<owner>` al publicar).

## Siguiente paso después del piloto

Publicar este repositorio como marketplace privado y hacerlo obligatorio por política de la organización, para que cada persona lo reciba al iniciar sesión.
