# Reglas DevOps — pipeline, ambientes y despliegue

Aplican a `.github/workflows/`, `Dockerfile`, infraestructura como código (Terraform, CloudFormation, CDK) y a cualquier script de despliegue o migración. El principio: **nadie despliega a mano**; un agente tampoco. Todo pasa por el pipeline, y el pipeline es código revisado en PR.

## Ambientes
- Tres ambientes mínimos: `dev` (local o efímero), `qa`, `prod`. Mismo artefacto en todos; solo cambia la configuración.
- Cada ambiente es un *environment* de GitHub con sus propios secretos. `prod` tiene revisores requeridos (mínimo uno, que no sea quien abrió el PR) y, si el negocio lo pide, ventana de despliegue.
- Un ambiente no conoce las credenciales de otro. Un agente nunca tiene acceso a `prod`; solo a `qa` a través del servidor MCP configurado.

## Pipeline mínimo por repositorio
1. **CI en cada PR:** restaurar dependencias, compilar, tests, linter/formateador, análisis de dependencias vulnerables. Falla el PR si falla cualquiera.
2. **Construir artefacto al fusionar a `main`:** imagen de contenedor o paquete, etiquetado con el SHA del commit y la versión. Inmutable: nunca se reconstruye para otro ambiente.
3. **Desplegar a `qa` automáticamente** con ese artefacto; correr migraciones; correr pruebas de humo (`smoke`).
4. **Desplegar a `prod`** con el mismo artefacto, solo tras aprobación humana en el environment y con la validación de QA registrada en el ticket.
5. **Verificar después:** pruebas de humo en prod, revisión de errores y latencia durante la ventana de observación declarada (mínimo 30 minutos), y rollback automático o manual si se supera el umbral.

## Credenciales y acceso
- GitHub Actions se autentica en AWS con **OIDC** (`aws-actions/configure-aws-credentials` con `role-to-assume`); nunca access keys como secretos del repositorio.
- Secretos de aplicación en AWS Secrets Manager o Parameter Store; el pipeline no los copia a archivos ni a logs. Nada de `echo $SECRETO`.
- Roles por ambiente con mínimo privilegio: el rol de `qa` no puede tocar recursos de `prod`.

## Artefactos y versiones
- Versionado semántico (`MAJOR.MINOR.PATCH`); etiqueta `v1.4.2` en git en cada release a prod.
- Changelog generado desde los tickets de los PRs incluidos (prefijo `TICKET-123:` en commits lo hace posible).
- Imágenes de contenedor: base oficial y fijada por digest, usuario no root, sin herramientas de build en la imagen final (multi-stage), escaneo de vulnerabilidades antes de desplegar.

## Migraciones de base de datos
- Corren en el pipeline, antes de desplegar la aplicación, con el usuario de migraciones (no el de la aplicación).
- **Compatibles hacia atrás** durante una release: agregar columna antes de usarla, nunca renombrar ni borrar en la misma release que deja de usarse (patrón *expand/contract*). Así el rollback de la aplicación no necesita rollback de datos.
- Migraciones sobre tablas transaccionales grandes en ventana de mantenimiento declarada, con snapshot previo.
- Lo que no se puede revertir (borrar datos, cambiar tipos) requiere aprobación explícita del tech lead en el PR.

## Despliegue
- Estrategia por defecto: *rolling* con health checks; para pagos, premios y sorteos, *blue/green* o *canary* con observación antes de pasar todo el tráfico.
- Feature flags para activar funcionalidad después de desplegar, no durante.
- Nunca `latest` en producción; siempre el SHA o la versión.
- Nada de pasos manuales "por esta vez": si hizo falta, es un bug del pipeline y se abre ticket.

## Rollback
- Todo despliegue a prod tiene documentado en el PR cómo se revierte: redesplegar la versión anterior (artefacto inmutable) y, si aplica, qué flag apagar.
- Un rollback es un despliegue más: pasa por el pipeline, se registra y se avisa. No se hace por SSH.
- Si el rollback requiere migración de datos inversa, el despliegue no debió salir sin ventana de mantenimiento.

## Observabilidad
- Logs estructurados centralizados (CloudWatch u otro) con el `correlation id` de la aplicación.
- Alarmas mínimas por servicio: tasa de errores 5xx, latencia p95, errores de conexión a base de datos, cola o batch sin avanzar. Cada alarma tiene dueño y canal.
- Las métricas de `metricas.yaml` del repositorio se publican desde el despliegue a `qa`, no después.
- Cada release registra: versión, SHA, tickets, quién aprobó, hora, resultado de humo. Eso alimenta las métricas DORA.

## Infraestructura como código
- Todo recurso de nube se declara en código y se aplica desde el pipeline con `plan` revisado en el PR; nada se crea desde la consola salvo incidentes, y lo creado así se importa al código esa misma semana.
- Estado remoto con bloqueo; nunca estado local en una laptop.
- Etiquetas obligatorias en cada recurso: proyecto, ambiente, cliente, dueño. Es lo que permite atribuir el costo.
