---
name: fix
description: Diagnostica un error reportado, encuentra la causa raíz y propone la corrección con un test que la reproduce
argument-hint: "[JIRA-123 o descripción del error]"
disable-model-invocation: true
---

Vas a atender el error $ARGUMENTS.

1. Reúne el contexto: ticket, captura, logs, pasos para reproducir. Si falta algo esencial, pídelo antes de seguir.
2. Reproduce el error. Escribe primero un test que falle demostrando el problema. Si no puedes reproducirlo, documenta qué intentaste y detente: no adivines.
3. Busca la causa raíz, no el síntoma. Revisa el historial de git del módulo (`git log -p`) para ver qué cambio lo introdujo.
4. Escribe en el ticket o en `docs/fixes/$ARGUMENTS.md`:
   - Causa raíz en dos frases.
   - Cambio que lo introdujo (commit y ticket, si se puede identificar).
   - Archivos involucrados.
   - Corrección propuesta.
5. Si la corrección es simple (menos de 50 líneas y un solo componente), impleméntala en la rama `fix/$ARGUMENTS`, haz que el test pase y abre el PR con la misma plantilla de `/asistentic:implementar`.
6. Si la corrección toca cálculo de premios, pagos, saldos, migraciones de base de datos o más de un componente, no la implementes: deja el diagnóstico y asigna al desarrollador dueño del módulo.
7. Al final, propón una regla, test o check que habría evitado el error. Esa propuesta es la entrada del postmortem.
