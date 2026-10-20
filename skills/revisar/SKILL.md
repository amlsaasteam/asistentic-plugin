---
name: revisar
description: Primera revisión automática de un PR contra las reglas de la empresa, para que el revisor humano se concentre en la lógica de negocio
argument-hint: "[número de PR o rama]"
disable-model-invocation: true
---

Vas a revisar el PR o rama $ARGUMENTS como primer revisor. Tu trabajo es dejar al revisor humano solo las decisiones de negocio.

## 0. Elegibilidad (no gastes tokens en vano)

Antes de leer el diff, verifica con `gh pr view $ARGUMENTS --json state,isDraft,additions,deletions,comments`:
- Si el PR está cerrado o fusionado: di que no aplica y termina.
- Si es borrador (*draft*): di que se revisará cuando esté listo y termina, salvo que el usuario pida revisarlo igual.
- Si ya existe un comentario "Revisión automática Asistentic" y no hay commits posteriores a él (`gh pr view --json commits`), di que ya está revisado y termina.
- Si el diff es menor a 10 líneas y solo toca documentación, configuración de CI o formato, publica solo "Verificado: cambio trivial" y termina.
- Si el diff es mayor a 800 líneas, dilo al inicio del comentario y sugiere dividirlo; revisa igual.

## 1. Contexto

1. Obtén el diff completo del PR contra la rama principal (`gh pr diff $ARGUMENTS` o `git diff main...$ARGUMENTS`).
2. Lee la spec correspondiente en `docs/specs/` y la plantilla del PR.
3. Lee `asistentic.yaml` para conocer el stack y `motor_datos`.

## 2. Agentes, según lo que cambió

Lanza en paralelo solo los que apliquen; cada uno trabaja en contexto limpio:

| Si el diff incluye… | Agente |
| --- | --- |
| Cualquier código | `asistentic:revisor-codigo` (siempre) |
| Archivos `.sql` o migraciones relacionales (SQL Server, Oracle, Aurora PostgreSQL/MySQL) | `asistentic:validador-sql` |
| Esquemas, repositorios, agregaciones o migraciones de MongoDB | `asistentic:validador-mongodb` |
| `try`/`catch`, reintentos, llamadas a servicios externos, colas, pagos, premios, saldos o batches | `asistentic:cazador-fallos-silenciosos` |
| Tests nuevos, modificados o eliminados, o una spec con criterios de aceptación | `asistentic:analista-tests` |
| `.github/workflows/`, `Dockerfile`, Terraform/CloudFormation/CDK, scripts de despliegue o migración | `asistentic:devops` |

Un diff puede necesitar los seis. Pásale a cada agente el diff, la ruta de la spec y el motor de datos.

## 3. Verificaciones propias

Verifica tú mismo, una por una:
- Cada criterio de aceptación de la spec tiene al menos un test que lo cubre (cruza con lo que diga `analista-tests`).
- No hay secretos, contraseñas, tokens ni cadenas de conexión en el diff.
- Los commits llevan el prefijo del ticket.
- Si hay cambio de base de datos, existe la migración versionada y, si la tabla o colección es nueva, tiene política de datos.
- Si hay tabla, colección o flujo nuevo, hay métrica asociada o una justificación de por qué no.
- El PR no toca cálculo de premios, pagos ni saldos sin que la spec lo marque como SENSIBLE y un humano lo revise explícitamente.
- **Evidencia:** la sección "Cómo se probó" del PR incluye la salida real de los tests (comando y resumen de resultados), no solo la frase "tests en verde". Si falta, es bloqueante: pide que se pegue.

## 4. Publicar

Consolida los hallazgos de los agentes y los tuyos. Elimina duplicados (el mismo problema visto por dos agentes se reporta una vez, con la confianza más alta). Descarta todo lo que tenga confianza menor a 80. Publica un solo comentario en el PR (`gh pr comment`) con esta estructura:

```markdown
## Revisión automática Asistentic

### Bloqueantes
Lo que impide aprobar, con archivo, línea y confianza `[85]`. Si no hay, escribe "Ninguno".

### Sugerencias
Mejoras que no bloquean.

### Verificado
Lista de reglas que pasaron y qué agentes corrieron.

### Para el revisor humano
Las 2 o 3 decisiones de negocio o diseño que sí requieren criterio humano, con la ruta del archivo.
```

Reglas:
- No apruebes ni fusiones el PR. Eso lo hace un humano.
- Sé específico: ruta de archivo y línea en cada hallazgo.
- Si no hay bloqueantes ni sugerencias con confianza suficiente, publica solo "Verificado" y "Para el revisor humano". No inventes hallazgos.
