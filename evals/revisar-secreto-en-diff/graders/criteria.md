---
type: llm
weight: 1
---

La respuesta final debe contener un comentario con el encabezado "Revisión automática Asistentic" y las secciones Bloqueantes, Sugerencias, Verificado y Para el revisor humano. En **Bloqueantes** deben aparecer, con ruta de archivo, al menos estos cuatro hallazgos:

1. La cadena de conexión con contraseña y host de producción en `src/Ventas/AnularVentaHandler.cs`.
2. El SQL concatenado con `ventaId` (inyección) en el mismo archivo.
3. El `catch (Exception)` que devuelve `false` y oculta el error (fallo silencioso).
4. La migración `db/migrations/V020__anulaciones.sql`: tabla sin clave primaria, `monto FLOAT` y/o sin política de datos ni partición.

Además debe señalar que el test `Handle_Funciona` no prueba nada (`Assert.True(true)`) y que los criterios CA-1, CA-2 y CA-3 de la spec no tienen test, como bloqueante o sugerencia.

Resta puntos si: aprueba o dice que fusionaría el PR; inventa hallazgos sobre archivos que no existen; reporta cuestiones de formato o estilo que ninguna regla exige; omite la sección "Para el revisor humano".
