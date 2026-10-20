---
name: pipeline
description: Genera o ajusta el pipeline de CI/CD del repositorio (PR → artefacto → QA automático → producción con aprobación) según las reglas DevOps de Asistentic y la sección despliegue de asistentic.yaml
argument-hint: "[crear | revisar | agregar-prod | agregar-migraciones]"
disable-model-invocation: true
---

Vas a trabajar el pipeline de este repositorio: $ARGUMENTS (si está vacío, asume `crear`).

1. Lee `asistentic.yaml`. Si no tiene sección `despliegue`, pide al usuario los datos mínimos (plataforma en AWS, herramienta de migraciones, URL de humo de QA, quién aprueba prod) o propón valores razonables marcados `propuesta: true`, y agrégala.
2. Lee `.github/workflows/` existente, `Dockerfile`, scripts de despliegue y `reglas/devops.md` del plugin.
3. Usa el agente `asistentic:devops` para:
   - `crear`: generar `ci.yml` y `cd.yml` completos para el stack y la plataforma declarados, con OIDC, environments `qa` y `prod`, migraciones antes de la aplicación, humo y ventana de observación.
   - `revisar`: auditar los workflows existentes contra `reglas/devops.md` y listar brechas con confianza ≥ 80.
   - `agregar-prod`: agregar el job `prod` con `environment: prod`, aprobación, misma imagen/paquete, humo y rollback documentado, sin tocar lo que ya despliega a QA.
   - `agregar-migraciones`: agregar el job de migraciones con la herramienta declarada, usuario de migraciones y verificación *expand/contract*.
4. Genera además `docs/despliegue.md` (máximo 60 líneas): cómo fluye un cambio de PR a producción, quién aprueba, cómo se revierte, qué alarmas existen y a quién avisan.
5. Lista lo que debe configurarse fuera del repositorio, con el paso exacto: environments y revisores en GitHub (Settings → Environments), rol OIDC en AWS con su *trust policy*, secretos por ambiente, protección de la rama principal.
6. Haz todo en una rama `chore/pipeline-asistentic` y abre el PR. No ejecutes ningún despliegue.

Reglas:
- Si el repositorio despliega hoy a mano o con un script en una laptop, dilo en el PR como la brecha principal; el pipeline reemplaza ese script, no lo invoca.
- Si el proyecto tiene varios repositorios (`depende_de` en `asistentic.yaml`), el orden de despliegue (bd → api → web) va en `docs/despliegue.md` y el `cd.yml` de cada uno solo despliega su componente.
