---
max_turns: 15
allowed_tools: [Read, Glob, Grep, Agent]
scaffold_script: ../fixtures/scaffold-dotnet.sh
tags: [tests, agentes]
---

Usa el agente `asistentic:analista-tests` sobre este repositorio: la spec está en `docs/specs/LOT-900.md`, los tests en `tests/` y el código en `src/Ventas/`. Devuelve su reporte completo.
