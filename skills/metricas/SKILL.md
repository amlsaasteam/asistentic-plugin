---
name: metricas
description: Propone el catálogo de métricas de sistema, de negocio y de datos para un proyecto, como archivo metricas.yaml versionado
disable-model-invocation: true
---

Vas a proponer el catálogo de métricas de este proyecto.

1. Lee `CLAUDE.md`, `asistentic.yaml` y explora los flujos principales del código: endpoints, procesos batch, pantallas con transacciones.
2. Propón métricas en tres grupos:
   - **Sistema:** disponibilidad, latencia p95 por endpoint crítico, errores por minuto. Son estándar; inclúyelas siempre.
   - **Negocio:** las 5 a 8 operaciones que definen el sistema (por ejemplo, tickets vendidos por hora, préstamos aprobados por día, tiempo de un cierre). Deduce cuáles son a partir del código y confírmalas con el usuario.
   - **Datos:** filas por nivel en cada tabla transaccional de `asistentic.yaml`, crecimiento mensual, traspasos ejecutados y fallidos.
3. Escribe `metricas.yaml`:

```yaml
- nombre: <snake_case>
  tipo: <sistema | negocio | datos>
  definicion: <una frase>
  calculo: <consulta SQL, contador de OpenTelemetry o fuente>
  umbral_alerta: <valor y condición, o null>
  dueno: <rol>
  propuesta: true
```

4. Explica en `docs/metricas.md` por qué propones cada métrica de negocio y qué decisión permite tomar.
5. Marca todo como `propuesta: true` y recuerda que el tech lead aprueba el catálogo como cualquier PR.
