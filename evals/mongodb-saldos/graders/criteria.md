---
type: llm
weight: 1
---

El reporte debe marcar como **Bloqueantes**: (1) mover `Saldo` (dinero) a un documento de MongoDB sin decisión de arquitectura citada; (2) `Saldo` como `double` en vez de `Decimal128`; (3) `Movimientos` como lista que crece sin tope dentro del documento; (4) `BsonDocument.Parse(filtroJson)` construyendo el filtro desde entrada del usuario (inyección de operadores). Como bloqueante o sugerencia: `FechaApertura` como string, `Skip` para paginar y la falta de `schemaVersion`. Resta puntos si no distingue bloqueantes de sugerencias o si no da una confianza numérica por hallazgo.
