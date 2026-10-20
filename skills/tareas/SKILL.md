---
name: tareas
description: Descompone una spec aprobada Grande (> 3 días) en tareas pequeñas, ordenadas y verificables, para ejecutarlas una por una con contexto limpio
argument-hint: "[JIRA-123]"
disable-model-invocation: true
---

Vas a descomponer la spec de $ARGUMENTS en tareas ejecutables. No escribas código.

1. Lee `docs/specs/$ARGUMENTS.md`. Si no existe o no está aprobada, detente. Si la estimación es Pequeña o Mediana, di que no hace falta este paso y sugiere `/asistentic:implementar` directo.
2. Lee `CLAUDE.md`, `asistentic.yaml` y explora los archivos que la spec cita.
3. Escribe `docs/specs/$ARGUMENTS.tareas.md` con esta estructura:

```markdown
# Tareas de $ARGUMENTS

Orden de ejecución: una tarea a la vez, en su propio commit. Cada tarea termina con su verificación en verde.

## T1 — <título en imperativo, 2 a 4 horas máximo>
- Criterio(s) de aceptación que cubre: CA-1, CA-3
- Archivos: `src/.../Archivo.cs` (modificar), `src/.../Nuevo.cs` (crear)
- Test primero: `Deberia_<resultado>_Cuando_<condicion>` en `tests/...`
- Cambio: qué se agrega o modifica, en 3 a 6 líneas; sin código completo
- Verificación: comando exacto y resultado esperado
- Depende de: ninguna | T<n>

## T2 — ...
```

Reglas para partir:
- Primero infraestructura (migraciones, modelos, contratos), después lógica, después pantallas e integraciones. Nada que dependa de algo que todavía no existe.
- Toda migración de base de datos es una tarea propia, la primera de su bloque, con su rollback.
- Toda tarea sobre zona SENSIBLE (premios, pagos, saldos) se marca `[SENSIBLE]` y lleva revisión humana antes de la siguiente.
- Ninguna tarea toca más de 5 archivos. Si una lo necesita, se divide.
- La última tarea siempre es "Verificación de extremo a extremo": el flujo completo en QA con los criterios de aceptación de la spec, uno por uno.

4. Termina con un resumen: número de tareas, cuáles son SENSIBLE y una estimación total. Recuerda al usuario que cada tarea se ejecuta con `/asistentic:implementar $ARGUMENTS T<n>` y que conviene `/clear` entre tareas para empezar con contexto limpio.
