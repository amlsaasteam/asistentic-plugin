---
name: rollback
description: Ejecuta el procedimiento de reversión de una release a producción por el pipeline (nunca a mano), registra el incidente y abre el postmortem
argument-hint: "[versión desplegada, p. ej. v1.4.0] [motivo breve]"
disable-model-invocation: true
---

Vas a revertir la release $ARGUMENTS. Un rollback es un despliegue más: pasa por el pipeline, lo aprueba una persona y queda registrado. No se hace por SSH, consola ni script directo.

1. Confirma con el usuario el motivo y el síntoma (alarma, error, monto incorrecto). Si el problema es de datos (premio mal calculado, saldo alterado), **detente**: revertir el código no corrige los datos y puede empeorarlos; escala al tech lead y a la persona dueña del módulo.
2. Lee `docs/releases/<version>.md` para saber la versión anterior, si hubo migraciones y si eran reversibles, y qué flags se activaron.
3. Decide el camino más corto y seguro, en este orden:
   - **Apagar el feature flag** si el cambio está detrás de uno. Es inmediato y no requiere despliegue.
   - **Redesplegar la versión anterior** por el pipeline (`workflow_dispatch` de `cd.yml` con la versión anterior, o el job de rollback si existe). Prepara el comando exacto para que una persona lo ejecute y apruebe; no lo ejecutes tú.
   - **Migración inversa** solo si la release la declaró reversible y el tech lead lo aprueba; si no, el camino es *fix forward* con `/asistentic:fix`.
4. Usa el agente `asistentic:devops` para verificar que el redespliegue no reintroduce una incompatibilidad (esquema expandido que la versión anterior no entiende) y para preparar las pruebas de humo posteriores.
5. Registra el incidente en `docs/incidentes/<fecha>-<version>.md`: hora de detección, síntoma, decisión, quién aprobó, hora de recuperación, impacto (clientes, ventas, tiempo). Esa hora de detección y recuperación alimenta el MTTR.
6. Avisa por el canal de notificaciones declarado: qué pasó, qué se hizo, qué sigue. Texto breve y sin culpas.
7. Termina abriendo el postmortem: `/asistentic:postmortem <ticket del incidente>`. La regla que salga de ahí debe evitar que vuelva a pasar, y su caso de eval va al plugin.
