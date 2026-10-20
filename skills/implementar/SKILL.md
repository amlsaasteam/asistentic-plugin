---
name: implementar
description: Implementa un ticket a partir de su spec aprobada, en una rama propia, con tests, y deja el PR listo para revisión
argument-hint: "[JIRA-123] [T2 opcional: tarea de docs/specs/JIRA-123.tareas.md]"
disable-model-invocation: true
---

Vas a implementar el ticket $ARGUMENTS siguiendo su spec aprobada. Si `$ARGUMENTS` incluye un identificador de tarea (`T1`, `T2`...), implementa solo esa tarea de `docs/specs/<TICKET>.tareas.md`, en su propio commit, y al terminar indica cuál sigue y sugiere `/clear`.

Antes de tocar código:

1. Lee `docs/specs/$ARGUMENTS.md`. Si no existe, detente y pide correr `/asistentic:spec $ARGUMENTS` primero.
2. Confirma con el usuario que la spec fue aprobada por el tech lead. Si dice que no, detente.
3. Lee `CLAUDE.md`, `asistentic.yaml` y, del plugin, `reglas/desarrollo.md`, `reglas/<stack>.md` y `reglas/<motor>.md` según `motor_datos`.
4. Crea la rama `feature/$ARGUMENTS` desde la rama principal (`main` o la que indique `CLAUDE.md`). Si la rama ya existe, cámbiate a ella.

Durante la implementación:

5. Si la spec tiene `docs/specs/<TICKET>.tareas.md`, ejecuta cada tarea con el agente `asistentic:desarrollador` (una invocación por tarea, en orden, pasándole ticket, identificador de tarea, criterios y archivos). Lee su resumen, verifica que la salida de tests esté pegada, y solo entonces pasa a la siguiente. Entre tareas sugiere `/clear` al usuario si el contexto ya es largo. Si no hay archivo de tareas, implementa tú directamente.
   Trabaja por criterios de aceptación, test primero: toma uno, escribe el test que lo verifica y córrelo para ver que **falla** por la razón correcta; luego escribe el mínimo código que lo hace pasar; corre los tests; limpia; y pasa al siguiente. Si escribiste código antes que su test, no lo conserves: escribe el test y vuelve a implementar desde él. Un test que pasa sin haber fallado antes no prueba nada.
   Si la spec es Grande (> 3 días), usa primero `/asistentic:tareas $ARGUMENTS` y ejecuta tarea por tarea.
6. Todo cambio de base de datos va en un archivo de migración versionado en la carpeta de migraciones del proyecto, nunca como script suelto. Si la spec declara una tabla transaccional nueva, la migración incluye el particionamiento según la política de datos; si declara una colección de MongoDB nueva, incluye sus índices, `$jsonSchema` y entrada en `asistentic.yaml`.
7. Cada commit lleva el prefijo `$ARGUMENTS:` seguido de una frase en imperativo.
8. No toques secretos, archivos `.env` ni cadenas de conexión. Si necesitas una conexión, usa el servidor MCP configurado para QA.

Al terminar:

9. Corre la suite completa de tests y el linter con el comando declarado en `verificacion.comando` de `asistentic.yaml`. Si algo falla, corrígelo antes de seguir. Guarda la salida: va en el PR.
10. Abre el PR contra la rama principal con esta plantilla:

```markdown
## Ticket
$ARGUMENTS — <título>

## Qué cambió
Lista corta por componente.

## Cómo se probó
Tests agregados o modificados, y qué cubre cada uno.

```
<comando de tests ejecutado y resumen real de su salida: cuántos pasaron, cuántos fallaron, duración>
```

## Cambios de base de datos
Migración incluida: sí/no. Nombre del archivo.

## Riesgos y cómo mitigarlos
De la spec, actualizados con lo que aprendiste al implementar.

## Checklist
- [ ] Spec aprobada
- [ ] Tests en verde (salida pegada arriba)
- [ ] Sin secretos ni credenciales en el código
- [ ] Migración versionada (si aplica)
```

11. Pide al usuario que corra `/asistentic:revisar` o que asigne un revisor humano.

Si durante la implementación descubres que la spec estaba incompleta o equivocada, detente, explica qué encontraste y propón actualizar la spec antes de continuar. No improvises fuera de la spec.
