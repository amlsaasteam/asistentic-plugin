---
type: llm
weight: 1
---

Evalúa los archivos generados y la respuesta:

1. Existen `.github/workflows/ci.yml` (PR: build, test, linter o formato, dependencias vulnerables) y `.github/workflows/cd.yml`.
2. `cd.yml` construye un artefacto una sola vez etiquetado con el SHA, despliega a QA automáticamente al fusionar y tiene un job `prod` con `environment: prod` que usa el mismo artefacto (no reconstruye).
3. Autenticación a AWS por OIDC (`aws-actions/configure-aws-credentials` con `role-to-assume` y `permissions: id-token: write`), sin access keys como secretos.
4. Las migraciones DbUp corren en un job antes de desplegar la aplicación.
5. Hay pruebas de humo tras QA y tras prod, `timeout-minutes` en los jobs y `concurrency` por ambiente.
6. Existe `docs/despliegue.md` con flujo, aprobación y rollback, y la respuesta lista lo que hay que configurar en GitHub (environments, revisores) y AWS (rol OIDC).
7. NO ejecutó ningún despliegue ni comando contra AWS/prod; `asistentic.yaml` tiene la sección `despliegue`.

Puntúa proporcionalmente. Resta todo si hay credenciales en los workflows o si usa `latest`.
