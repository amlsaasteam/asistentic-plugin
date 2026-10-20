# Reglas SQL Server

Aplican a scripts `.sql`, migraciones y stored procedures para SQL Server.

## Migraciones
- Todo cambio de esquema es una migración versionada (DbUp o Flyway). Una migración fusionada no se edita; se agrega otra.
- Cada migración tiene rollback o explica por qué no.

## Tablas
- Clave primaria siempre. Columna de fecha de la transacción indexada.
- Tablas transaccionales particionadas por fecha desde su creación, según la política en `asistentic.yaml`.
- Columnas con datos personales o financieros declaran cifrado o enmascarado.

## Stored procedures
- `SET NOCOUNT ON` al inicio.
- Manejo de errores con `BEGIN TRY ... END TRY BEGIN CATCH ... END CATCH` y `THROW`.
- Sin `SELECT *`. Sin cursores donde una operación de conjunto resuelve.
- Parámetros tipados con el mismo tipo de la columna (evita conversiones implícitas).

## Consultas
- Nunca funciones sobre columnas indexadas en el `WHERE` (`WHERE YEAR(fecha) = ...` está prohibido; usar rangos).
- Toda consulta sobre tabla particionada incluye la clave de partición.
- `WITH (NOLOCK)` solo en reportes de solo lectura y con justificación en comentario.

## Rendimiento
- Toda consulta nueva sobre tabla transaccional se acompaña de su plan de ejecución revisado en QA.
- Índices nuevos se justifican en la spec con la consulta que los usa.
