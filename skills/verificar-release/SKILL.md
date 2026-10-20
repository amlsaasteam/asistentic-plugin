---
name: verificar-release
description: Verifica una release recién desplegada a producción durante su ventana de observación (humo, errores, latencia, métricas de negocio) y decide si se cierra o se revierte
argument-hint: "[v1.4.0]"
disable-model-invocation: true
---

Vas a verificar la release $ARGUMENTS en producción. Solo observas: no cambias nada en prod ni ejecutas comandos contra ella fuera de lecturas de monitoreo.

1. Lee `docs/releases/$ARGUMENTS.md`: umbrales de rollback, ventana de observación, pruebas de humo, métricas de negocio afectadas.
2. Ejecuta o lee lo que el pipeline ya corrió: resultado de las pruebas de humo (`gh run view` del job `prod`), hora de despliegue.
3. Durante la ventana (o al cierre, si te invocan después), consulta por los medios de solo lectura configurados (CloudWatch, Sentry, el portal de métricas o el servidor MCP de monitoreo):
   - Tasa de errores 5xx y excepciones nuevas comparadas con la hora previa al despliegue.
   - Latencia p95 de los endpoints tocados por la release.
   - Las métricas de negocio de `metricas.yaml` afectadas (ventas por minuto, pagos procesados, premios calculados): deben seguir en su rango habitual para la hora y el día.
   - Colas, batches o jobs que dependan del cambio: que avancen.
4. Escribe el resultado en `docs/releases/$ARGUMENTS.md`, sección "Verificación en producción": hora, cada indicador con valor antes y después, veredicto.
5. Veredicto:
   - **Cerrada:** todo dentro de umbral al terminar la ventana. Registra la hora y actualiza los tickets.
   - **Revertir:** algún umbral superado o una métrica de negocio fuera de rango. Lanza de inmediato `/asistentic:rollback $ARGUMENTS <motivo>` y avisa por el canal declarado.
   - **Observar más:** señales ambiguas; extiende la ventana una vez, con hora de nueva revisión y responsable.
6. Avisa por el canal de notificaciones el veredicto en dos líneas. Las horas de despliegue, detección y cierre alimentan las métricas DORA del proyecto.
