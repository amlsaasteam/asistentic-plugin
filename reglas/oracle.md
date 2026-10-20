# Reglas Oracle

Aplican a scripts `.sql`, paquetes PL/SQL y migraciones para Oracle (incluida la versión de AWS RDS for Oracle).

## Migraciones
- Todo cambio de esquema es una migración versionada (Flyway o Liquibase). Una migración fusionada no se edita; se agrega otra.
- Cada migración tiene rollback o explica por qué no. DDL en Oracle hace commit implícito: una migración no mezcla DDL con DML que deba revertirse junto.
- Objetos siempre con esquema explícito (`FIN.IT_INVENTARIO`), nunca dependientes del usuario de conexión.

## Tablas
- Clave primaria siempre, con nombre de constraint explícito (`PK_<TABLA>`). Sin constraints con nombre generado (`SYS_C...`).
- Toda columna `NOT NULL` nueva sobre tabla con datos lleva `DEFAULT` en la misma sentencia, o la migración rellena antes de aplicar la restricción (evita `ORA-01400` y `ORA-02296`).
- Tablas transaccionales particionadas por rango de fecha (`INTERVAL` mensual o diario) desde su creación, según la política en `asistentic.yaml`. Índices locales salvo justificación.
- Columnas con datos personales o financieros declaran cifrado (TDE o `DBMS_CRYPTO`) o enmascarado (`DBMS_REDACT`).
- Secuencias con `CACHE` razonable (≥ 20) para tablas de alta inserción; nunca `NOCACHE` en transaccionales.

## PL/SQL
- Lógica en paquetes, no en procedimientos sueltos ni en triggers. Un trigger solo audita o valida; nunca contiene reglas de negocio nuevas.
- Manejo de errores con `EXCEPTION WHEN ... THEN` y `RAISE_APPLICATION_ERROR` con códigos del rango del proyecto; nunca `WHEN OTHERS THEN NULL`.
- Sin `SELECT *`. Variables con `%TYPE` y `%ROWTYPE`, no tipos duplicados a mano.
- Operaciones por conjunto: `FORALL` y `BULK COLLECT ... LIMIT` en lugar de cursores fila por fila.
- `COMMIT` lo decide quien llama, no el paquete, salvo batches con punto de reinicio documentado.
- Binds siempre; nunca SQL dinámico con concatenación (`EXECUTE IMMEDIATE ... USING`).

## Consultas
- Nunca funciones sobre columnas indexadas en el `WHERE` (`TRUNC(fecha) = ...` está prohibido; usar rangos). Si es inevitable, índice basado en función justificado.
- Toda consulta sobre tabla particionada incluye la clave de partición para habilitar *partition pruning*.
- Sin `NVL` sobre columnas indexadas en predicados; modelar con `NOT NULL` + `DEFAULT`.
- Hints solo con justificación en comentario y plan de ejecución adjunto.

## Rendimiento
- Toda consulta nueva sobre tabla transaccional se acompaña de su plan (`DBMS_XPLAN.DISPLAY_CURSOR`) revisado en QA.
- Estadísticas actualizadas forman parte del procedimiento de despliegue de migraciones grandes.
- Índices nuevos se justifican en la spec con la consulta que los usa; índices sin uso se eliminan en la siguiente ventana.
