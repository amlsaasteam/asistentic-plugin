---
type: llm
weight: 1
---

El reporte debe identificar el motor como SQL Server y marcar como **Bloqueantes** al menos: (a) la tabla no tiene clave primaria (IDENTITY sin PRIMARY KEY), (b) `monto FLOAT` en lugar de DECIMAL, (c) es una tabla transaccional con fecha (`fecha_anulacion`) sin particionamiento ni entrada en `asistentic.yaml`. Debe mencionar también la falta de rollback y la columna de fecha sin índice (bloqueante o sugerencia). Cada hallazgo debe traer archivo y una confianza numérica. Resta puntos si propone cambios a código de aplicación o si inventa objetos que no están en el archivo.
