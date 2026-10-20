# Reglas Amazon Aurora (PostgreSQL y MySQL)

Aplican a scripts `.sql` y migraciones para Aurora PostgreSQL y Aurora MySQL. Donde el motor importa, se indica.

## Arquitectura Aurora (aplica a ambos)
- Dos endpoints siempre configurados: el de escritura (cluster endpoint) y el de lectura (reader endpoint). Reportes, consultas de listado y procesos de solo lectura usan el reader. La aplicación nunca apunta a una instancia por su nombre.
- La cadena de conexión viene de la bóveda (Secrets Manager) con rotación; la aplicación obtiene credenciales en el arranque, nunca las guarda en configuración versionada.
- Conexiones a través de RDS Proxy o un pool en la aplicación con límite declarado. Lambdas y batches cortos siempre por RDS Proxy.
- Toda operación reintenta una vez ante error de conexión (failover tarda segundos); las escrituras que mueven dinero son idempotentes.
- Aurora Serverless v2 solo para ambientes de QA o cargas intermitentes declaradas; producción transaccional usa instancias aprovisionadas, salvo decisión de arquitectura documentada.
- Backups: retención automática ≥ 7 días y *backtrack* (MySQL) o PITR habilitado. Las migraciones grandes crean un snapshot manual antes.

## Migraciones
- Migración versionada (Flyway, Liquibase, DbUp o la del framework: EF Core, Prisma, Alembic). Una migración fusionada no se edita; se agrega otra.
- Cada migración tiene rollback o explica por qué no.
- PostgreSQL: DDL transaccional, una migración puede revertirse completa. MySQL: DDL hace commit implícito; no mezclar DDL con DML reversible.
- Cambios en tablas grandes: PostgreSQL usa `CREATE INDEX CONCURRENTLY` y `ADD COLUMN` con `DEFAULT` (sin reescritura desde v11); MySQL usa `ALGORITHM=INPLACE, LOCK=NONE` o `pt-online-schema-change`/`gh-ost`. Si la operación bloquea la tabla, va en ventana de mantenimiento marcada en el PR.
- Esquemas explícitos en PostgreSQL (`public` solo en proyectos pequeños); nunca depender del `search_path` del usuario.

## Tablas
- Clave primaria siempre. En PostgreSQL `BIGINT GENERATED ALWAYS AS IDENTITY` o `UUID` (v7 si está disponible); en MySQL `BIGINT AUTO_INCREMENT`. Nunca `INT` en transaccionales.
- Columna de fecha de la transacción en `TIMESTAMPTZ` (PostgreSQL) o `DATETIME(6)` en UTC (MySQL), indexada.
- Tablas transaccionales particionadas por rango de fecha desde su creación (PostgreSQL: particionamiento declarativo con `pg_partman` para crear particiones automáticamente; MySQL: `PARTITION BY RANGE` sobre la fecha), según la política en `asistentic.yaml`.
- Montos en `NUMERIC(18,2)`/`DECIMAL(18,2)`; nunca `FLOAT` ni `DOUBLE`.
- Columnas con datos personales o financieros declaran cifrado en reposo (KMS en el clúster es obligatorio) y, si aplica, cifrado a nivel de columna (`pgcrypto`) o enmascarado en la vista de reportes.
- `JSONB` (PostgreSQL) o `JSON` (MySQL) solo para atributos variables; nunca para campos que se filtran o se suman en reportes.

## Consultas
- Siempre parametrizadas. Nunca concatenar.
- Nunca funciones sobre columnas indexadas en el `WHERE` (`DATE(fecha) = ...` prohibido; usar rangos `>= ... AND < ...`).
- Toda consulta sobre tabla particionada incluye la clave de partición.
- Paginación por *keyset* (`WHERE id > ? ORDER BY id LIMIT ?`) en listas grandes; `OFFSET` solo en pantallas pequeñas.
- PostgreSQL: índices parciales y de cobertura (`INCLUDE`) cuando una consulta lo justifica; `EXPLAIN (ANALYZE, BUFFERS)` adjunto en el PR para consultas nuevas sobre transaccionales.
- MySQL: `EXPLAIN` adjunto; evitar `SELECT ... FOR UPDATE` sin índice en el predicado.
- Transacciones cortas. Nada de esperar entrada del usuario ni llamadas HTTP con una transacción abierta.

## Rendimiento y operación
- Performance Insights habilitado en todos los clústeres; consultas con más del 5% de carga en QA se revisan antes de ir a producción.
- `VACUUM`/`ANALYZE` automáticos verificados en PostgreSQL para tablas de alta rotación; `innodb_buffer_pool` dimensionado en MySQL.
- Índices nuevos se justifican en la spec con la consulta que los usa; índices sin uso (`pg_stat_user_indexes`, `sys.schema_unused_indexes`) se eliminan.
- Datos tibios y fríos se mueven por el motor de transferencia de Asistentic (particiones a S3 vía `aws_s3` en PostgreSQL o exportación a S3 en MySQL); la aplicación los consulta a través de la librería de acceso, nunca con rutas propias.
