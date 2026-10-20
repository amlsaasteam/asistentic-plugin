# Reglas MongoDB

Aplican a repositorios que usan MongoDB (Atlas, Amazon DocumentDB o autogestionado). Donde DocumentDB difiere, se indica.

## Cuándo sí y cuándo no
- MongoDB es para documentos con estructura variable, catálogos, configuración, eventos y lecturas por documento completo.
- Saldos, premios, pagos, asientos contables y cualquier dato que exija transacciones entre varias entidades viven en el motor relacional del proyecto. Si la spec propone moverlos a MongoDB, es una decisión de arquitectura y requiere aprobación explícita.
- Un proyecto declara en `asistentic.yaml` qué colecciones son transaccionales (alta inserción con fecha) para aplicar la política de datos.

## Modelado
- Diseñar por patrón de acceso, no por normalización. Un documento por lo que la pantalla o el proceso lee de una vez.
- Embeber lo que se lee junto y crece poco (dirección del cliente). Referenciar lo que crece sin límite (movimientos de una cuenta): un documento nunca debe acercarse a 16 MB ni crecer por *array* sin tope.
- Todo documento lleva `schemaVersion` (entero). Un cambio de forma incrementa la versión y la aplicación lee ambas hasta que el script de migración termine.
- Montos en `Decimal128`, nunca `double`. Fechas en `Date` (UTC), nunca strings.
- Nombres de campos cortos y consistentes en toda la colección; sin campos que cambian de tipo entre documentos.
- Validación de esquema (`$jsonSchema`) en toda colección de negocio con `validationLevel: moderate` como mínimo. DocumentDB no la soporta: la validación va en la capa de aplicación con un esquema versionado en el repositorio.

## Migraciones
- Cambios de índices y de forma de documentos van en scripts de migración versionados (`migrate-mongo`, `mongock` o el del framework), nunca ejecutados a mano en Compass.
- Migraciones de datos por lotes (`limit` + `_id` como cursor), reanudables, con registro de progreso. Nunca `updateMany` sin filtro sobre una colección grande en horario de operación.
- Creación de índices siempre en segundo plano (comportamiento por defecto desde 4.2) y fuera de hora pico en colecciones grandes.

## Índices y consultas
- Toda consulta de producción está cubierta por un índice; `explain("executionStats")` adjunto en el PR para consultas nuevas; un `COLLSCAN` sobre colección de negocio es bloqueante.
- Orden de campos en índices compuestos: igualdad, orden, rango (ESR).
- Índice TTL en colecciones de eventos, sesiones y logs con la retención declarada en `asistentic.yaml`.
- Máximo razonable de índices por colección (orientativo: 10); cada uno justificado por una consulta.
- Paginación por *keyset* (`_id` o campo indexado); `skip` solo en pantallas pequeñas.
- Agregaciones: `$match` y `$project` lo más temprano posible; `$lookup` solo sobre campos indexados y nunca en rutas de alta frecuencia.
- Nunca construir filtros concatenando entrada del usuario ni aceptar operadores (`$where`, `$regex` sin anclar, `$gt` inyectado) desde el cliente; validar y tipar cada filtro.

## Escrituras y consistencia
- `writeConcern: majority` en todo lo que importe; `readConcern: majority` donde la lectura decida algo.
- Transacciones multi-documento solo donde no hay alternativa de modelado, cortas y sin llamadas externas dentro.
- Operaciones idempotentes (`updateOne` con `upsert` y clave natural) en integraciones y reintentos.
- Nada de lógica de negocio en *change streams* o triggers de Atlas sin registro en la spec.

## Seguridad y operación
- Credenciales desde la bóveda; usuarios por aplicación con el rol mínimo (`readWrite` sobre su base, nunca `root` ni `dbAdmin` en producción).
- Cifrado en reposo obligatorio; cifrado a nivel de campo (CSFLE o Queryable Encryption) para cédula, cuenta y tarjeta.
- Acceso de red solo por VPC peering o private endpoint; nunca `0.0.0.0/0` en la lista de IPs.
- Backups continuos con PITR habilitado; una restauración probada por trimestre.
- Atlas Performance Advisor (o `db.currentOp` y el *profiler* en nivel 1 con umbral de 100 ms) revisado antes de cada paso a producción.
- Datos tibios y fríos se mueven por el motor de transferencia de Asistentic (Online Archive en Atlas, o exportación a S3); la aplicación los consulta a través de la librería de acceso.
