---
name: validar-qa
description: Genera el plan de validación en QA de un ticket a partir de su spec, verifica lo automatizable contra el ambiente de QA y deja el registro de resultados que exige la compuerta de producción
argument-hint: "[JIRA-123]"
disable-model-invocation: true
---

Vas a validar en QA el ticket $ARGUMENTS. El cambio ya está desplegado en QA por el pipeline; si no lo está, detente y dilo.

1. Lee `docs/specs/$ARGUMENTS.md` (criterios de aceptación), el PR fusionado y `asistentic.yaml` (`despliegue.ambientes.qa`).
2. Genera `docs/qa/$ARGUMENTS.md` con un caso por criterio de aceptación, en esta forma:

```markdown
# Validación QA — $ARGUMENTS
Versión desplegada: <SHA o versión> · Fecha: <fecha> · Validó: <persona>

| # | Criterio | Pasos | Dato de prueba | Resultado esperado | Resultado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- |
| CA-1 | ... | 1. ... 2. ... | ... | ... | ⬜ | |

## Regresión mínima
Los 3 a 5 flujos del sistema que el cambio podría afectar (venta, cierre, pago, reporte), con pasos.

## Datos sensibles
Si el ticket es SENSIBLE: qué validación extra hace el tech lead (cuadre de montos, premio calculado contra caso conocido).

## Veredicto
⬜ Aprobado para producción · ⬜ Rechazado (tickets de corrección: ...)
```

3. Lo que puedas verificar sin una persona, verifícalo y rellena el resultado con evidencia real:
   - La prueba de humo de QA (`url_smoke`) responde.
   - Endpoints nuevos responden con los códigos esperados (usa `curl` contra QA, nunca contra prod).
   - Consultas de verificación contra la base de QA a través del servidor MCP configurado (por ejemplo, que la migración creó la tabla con su partición, que un registro de prueba quedó con usuario y fecha).
   - Logs de QA sin errores nuevos desde el despliegue.
   Marca lo que requiere a una persona (pantallas, flujos de caja, dispositivos) como "Manual: pendiente".
4. Si algún caso automatizable falla, abre el ticket de corrección con `/asistentic:fix` o deja el enlace, y marca el veredicto como Rechazado.
5. Termina con el resumen para el ticket de Jira: casos totales, pasados, pendientes manuales, fallidos, y quién debe firmar el veredicto. La compuerta de producción (`/asistentic:release`) exige este archivo con veredicto Aprobado y firmado por una persona.
