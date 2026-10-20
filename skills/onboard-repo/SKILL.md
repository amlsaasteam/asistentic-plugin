---
name: onboard-repo
description: Analiza un repositorio existente y genera su CLAUDE.md, asistentic.yaml, política de datos propuesta y lista de brechas para incorporarlo al modelo Asistentic
disable-model-invocation: true
---

Vas a incorporar este repositorio al modelo Asistentic. No cambies código de la aplicación; solo generas configuración y un diagnóstico.

1. Explora el repositorio: estructura de carpetas, lenguaje y framework, cómo se compila y se prueba, dónde están las migraciones o scripts de base de datos, qué ambientes y cadenas de conexión aparecen (sin leer sus valores), y si tiene pipeline.
2. Genera `CLAUDE.md` en la raíz, de no más de 80 líneas, con: qué es el sistema, arquitectura en 5 líneas, comandos para compilar, probar y correr, convenciones que ya existen en el código, zonas sensibles (cálculo de premios, pagos, saldos, datos personales) y lo que un agente nunca debe tocar.
3. Genera `asistentic.yaml` con esta estructura:

```yaml
proyecto: <nombre del sistema de negocio>
componente: <web | api | movil | bd | batch>
depende_de: []
stack: <dotnet | java | node | python | otro>
motor_datos: [<sqlserver | oracle | aurora-postgresql | aurora-mysql | mongodb>]   # uno o varios
verificacion:
  comando: <dotnet test | mvn -q test | npm test>   # lo corre el hook Stop antes de dar por terminada una tarea
  timeout_segundos: 600
despliegue:                      # lo completa /asistentic:pipeline; aquí solo lo que veas en el repo
  plataforma: <ecs | beanstalk | lambda | ec2 | eks | iis | desconocida>
  como_se_despliega_hoy: <pipeline | script | manual>   # brecha si no es pipeline
ambientes:
  dev: {}
  qa: {}
  prod: {}
tablas_transaccionales:
  - nombre: <tabla>
    clave_particion: <columna de fecha>
    dias_caliente: 90
    dias_tibio: 730
    anios_retencion: 7
    propuesta: true
colecciones_transaccionales:        # solo si hay MongoDB
  - nombre: <coleccion>
    campo_fecha: <campo>
    dias_caliente: 90
    dias_retencion_ttl: 730
    propuesta: true
```

   Detecta el motor de datos por las dependencias y cadenas de conexión (sin leer valores): `System.Data.SqlClient`/`Microsoft.Data.SqlClient` → sqlserver; `Oracle.ManagedDataAccess`/`ojdbc` → oracle; `Npgsql`/`pg`/`postgresql` → aurora-postgresql; `MySql.Data`/`mysql-connector` → aurora-mysql; `MongoDB.Driver`/`mongoose`/`spring-data-mongodb` → mongodb. Si hay más de uno, lista todos.

   Para las tablas transaccionales, propón la política a partir de lo que veas en el código (tablas con fecha, inserts frecuentes). Marca cada entrada con `propuesta: true` para que el tech lead la revise.
4. Si no existe pipeline de GitHub Actions, genera `.github/workflows/ci.yml` con build, tests y linter según el stack. No incluyas despliegue todavía: eso lo hace `/asistentic:pipeline` en un PR aparte, y lo anotas como siguiente paso.
5. Si no existe plantilla de PR, genera `.github/pull_request_template.md` con la misma plantilla de `/asistentic:implementar`.
6. Escribe `docs/onboarding-asistentic.md` con las brechas encontradas, ordenadas por riesgo: sin tests, secretos en el código, SQL sin migraciones, tablas grandes sin partición, colecciones sin índices o sin validación de esquema, reportes apuntando al endpoint de escritura de Aurora, despliegue manual o por script desde una laptop, credenciales de producción en máquinas de desarrolladores, ausencia de métricas. Compara el código con `reglas/desarrollo.md` y `reglas/<motor>.md` del plugin. Para cada brecha, una acción concreta.
7. Resume en diez líneas qué generaste y qué debe revisar el tech lead antes de aprobar el PR.

Haz todo en una rama `chore/onboard-asistentic` y abre el PR.
