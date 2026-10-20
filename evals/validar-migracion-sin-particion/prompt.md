---
max_turns: 15
allowed_tools: [Read, Glob, Grep, Agent]
scaffold_script: ../fixtures/scaffold-dotnet.sh
tags: [sql, agentes]
---

Usa el agente `asistentic:validador-sql` para validar el archivo `db/migrations/V020__anulaciones.sql` de este repositorio (motor en `asistentic.yaml`). Devuelve su reporte completo.
