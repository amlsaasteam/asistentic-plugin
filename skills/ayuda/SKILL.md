---
name: ayuda
description: Explica el ciclo Asistentic y qué comando usar en cada paso
disable-model-invocation: true
---

Explica al usuario, en español y en menos de 40 líneas, el ciclo Asistentic y sus comandos:

| Paso | Comando | Quién lo corre | Qué produce |
|---|---|---|---|
| Incorporar un repo existente | `/asistentic:onboard-repo` | Tech lead | CLAUDE.md, asistentic.yaml, CI, brechas |
| Crear o ajustar el pipeline | `/asistentic:pipeline` | Tech lead / DevOps | ci.yml, cd.yml (QA automático, prod con aprobación), docs/despliegue.md |
| Catálogo de métricas | `/asistentic:metricas` | Tech lead | metricas.yaml |
| Especificar un ticket | `/asistentic:spec JIRA-123` | Desarrollador | docs/specs/JIRA-123.md (aprueba el tech lead) |
| Partir una spec Grande | `/asistentic:tareas JIRA-123` | Desarrollador | docs/specs/JIRA-123.tareas.md |
| Implementar (con spec) | `/asistentic:implementar JIRA-123 [T2]` | Desarrollador (agente `desarrollador` por tarea) | Rama, tests, PR |
| Cambio pequeño (sin spec) | `/asistentic:desarrollar JIRA-124 agregar campo X` | Desarrollador | Rama, tests, PR |
| Revisar | `/asistentic:revisar 45` | Desarrollador o revisor | Comentario en el PR (6 agentes); aprueba y fusiona un humano |
| → el pipeline despliega a QA | automático al fusionar | — | Artefacto, migraciones, humo en QA |
| Validar en QA | `/asistentic:validar-qa JIRA-123` | QA / desarrollador | docs/qa/JIRA-123.md con veredicto firmado |
| Release a producción | `/asistentic:release 1.4.0` | Tech lead | CHANGELOG, docs/releases/v1.4.0.md, PR de release; aprueba un humano en el environment prod |
| Verificar en producción | `/asistentic:verificar-release v1.4.0` | Quien observa | Veredicto: cerrada / revertir / observar más |
| Revertir | `/asistentic:rollback v1.4.0 motivo` | Tech lead | Redespliegue por pipeline, docs/incidentes/, postmortem |
| Corregir un error | `/asistentic:fix JIRA-456` | Desarrollador | Diagnóstico, test que reproduce, PR si es simple |
| Cerrar un incidente | `/asistentic:postmortem JIRA-456` | Tech lead | Postmortem, regla nueva y su caso de eval |
| Mantener CLAUDE.md | `/asistentic:revisar-claude-md` | Quien termina una sesión | Propuesta de cambios al CLAUDE.md |

Compuertas humanas, en orden: spec aprobada → PR aprobado y fusionado → QA firmado → environment prod aprobado. Ningún comando las salta.

Menciona que las reglas viven en `reglas/` del plugin: `desarrollo.md` (generales), por stack (`dotnet`, `java`), por motor de datos (`sqlserver`, `oracle`, `aurora`, `mongodb`) y `devops.md` (pipeline, ambientes, despliegue, rollback).

Menciona que hay cuatro hooks que no se pueden saltar (push a la rama principal, ticket en el commit, secretos y patrones peligrosos en lo que se escribe, despliegues o comandos contra producción) y uno que corre la verificación declarada en `asistentic.yaml` antes de dar por terminada una tarea con cambios.

Recuérdale las cuatro reglas que no se negocian: la IA propone y una persona aprueba; cero credenciales en la máquina; todo cambio con ticket, rama y PR; y cada error termina en una regla nueva.
