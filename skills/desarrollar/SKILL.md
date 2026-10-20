---
name: desarrollar
description: Desarrolla un cambio pequeño (sin spec formal) aplicando las reglas de desarrollo y del stack, con tests y PR. Para tickets grandes usa spec + implementar.
argument-hint: "[JIRA-123] <qué hay que hacer>"
disable-model-invocation: true
---

Vas a desarrollar lo que pide el usuario: $ARGUMENTS

Este comando es para cambios de medio día o menos: un endpoint, un campo, un refactor acotado, una validación, un reporte pequeño. Si al explorar ves que el cambio toca más de 5 archivos, una zona sensible, o un cambio de esquema en tabla transaccional, detente y pide `/asistentic:spec` primero.

## Antes de escribir código

1. Identifica el ticket. Si `$ARGUMENTS` no empieza con una clave de Jira, pregúntala; sin ticket no hay rama ni commit.
2. Lee `CLAUDE.md` y `asistentic.yaml` del repositorio.
3. Lee las reglas que apliquen desde el plugin, en este orden:
   - `reglas/desarrollo.md` (siempre).
   - `reglas/<stack>.md` según `asistentic.yaml` (`dotnet.md`, `java.md`).
   - `reglas/<motor>.md` según `motor_datos` de `asistentic.yaml` (`sqlserver.md`, `oracle.md`, `aurora.md`, `mongodb.md`). Si hay más de un motor, lee todos.
4. Explora el código que vas a tocar y lo que lo usa. Resume en 5 líneas qué vas a cambiar y por qué, y espera confirmación del usuario.
5. Crea la rama `feature/<TICKET>` (o `fix/<TICKET>` si es corrección) desde la rama principal.

## Mientras desarrollas

6. Sigue las convenciones que ya existen en el repositorio aunque no coincidan con tu preferencia. Si una convención existente contradice una regla del plugin, aplica la regla del plugin solo en código nuevo y anótalo en el PR.
7. Escribe primero el test que describe el comportamiento esperado, luego el código. Corre los tests después de cada cambio.
8. Cambios de datos: siempre migración versionada (relacional) o script de migración de documentos con versión (MongoDB). Nunca scripts sueltos.
9. No toques secretos, `.env`, cadenas de conexión ni configuración de producción. Conexiones solo a QA a través del servidor MCP configurado.
10. Commits pequeños con prefijo `<TICKET>:` y frase en imperativo.

## Antes de abrir el PR

11. Pasa esta lista y corrige lo que falle:
   - Suite de tests y linter en verde.
   - Ninguna consulta dentro de un bucle.
   - Ninguna entrada del usuario concatenada en SQL, filtros de Mongo, rutas o comandos.
   - Ningún dato personal o financiero en logs ni mensajes de error.
   - Funciones de menos de 60 líneas; sin código duplicado evidente.
   - Si agregaste una lista o endpoint, tiene paginación y código de estado correcto.
   - Si agregaste una tabla, colección o flujo de negocio, hay métrica en `metricas.yaml` o una línea que explica por qué no.
12. Abre el PR con la plantilla del repositorio. En "Cómo se probó" lista los tests nuevos y pega la salida real del comando de tests (`verificacion.comando` de `asistentic.yaml`): sin esa evidencia `/asistentic:revisar` lo marca como bloqueante. En "Riesgos" di qué podría romperse y cómo verificarlo en QA.
13. Pide al usuario que corra `/asistentic:revisar <PR>`.

Si en cualquier punto descubres que el cambio es más grande de lo que parecía, detente, explica qué encontraste y propón pasar a `/asistentic:spec`. No improvises.
