---
name: release
description: Prepara una release a producción: verifica las compuertas (QA aprobado, PRs revisados), genera versión y changelog, crea el PR de release y deja listo el despliegue para que un humano lo apruebe en el pipeline
argument-hint: "[versión opcional, p. ej. 1.4.0]"
disable-model-invocation: true
---

Vas a preparar una release a producción. Nunca despliegas tú: preparas todo para que el pipeline lo haga tras aprobación humana.

## 1. Compuertas (si alguna falla, detente y dilo)

1. Lista los commits en la rama principal desde la última etiqueta `v*` (`git log --oneline <ultima-etiqueta>..HEAD`) y extrae los tickets por su prefijo.
2. Para cada ticket verifica que exista `docs/qa/<TICKET>.md` con veredicto **Aprobado** y nombre de quien validó. Sin eso, el ticket no sale: propón dejarlo fuera (revertir el commit en una rama de release) o esperar.
3. Verifica que cada PR fusionado tiene el comentario "Revisión automática Asistentic" y aprobación humana (`gh pr view --json reviews`).
4. Si hay migraciones en el rango, confirma en el PR que son compatibles hacia atrás (*expand/contract*) o que hay ventana de mantenimiento acordada; si tocan tablas transaccionales grandes, exige snapshot previo en el pipeline.
5. Lee `asistentic.yaml` → `despliegue.ambientes.prod` (aprobadores, estrategia, observación, humo).

## 2. Preparar

6. Versión: la indicada en `$ARGUMENTS` o, si no, semántica según el contenido (solo correcciones → PATCH; funcionalidad → MINOR; cambio incompatible de API o esquema → MAJOR).
7. Genera `CHANGELOG.md` (sección nueva arriba) agrupando por ticket: título, tipo, PR, y una línea de "cómo se revierte" cuando aplique (flag, versión anterior).
8. Genera `docs/releases/v<version>.md`: tickets incluidos, migraciones y su reversibilidad, plan de despliegue (estrategia, orden si hay varios repositorios), pruebas de humo, umbrales de rollback (errores 5xx, latencia), ventana de observación, y quién aprueba y quién observa.
9. Usa el agente `asistentic:devops` para revisar que el workflow `cd.yml` cubre lo que el plan dice (environment `prod`, misma imagen, humo, observación). Si falta algo, el PR de release lo señala como bloqueante.
10. Crea la rama `release/v<version>`, haz commit de changelog y plan con mensaje `chore: release v<version>`, abre el PR hacia la rama principal con el plan en la descripción y asigna a los aprobadores declarados.

## 3. Entregar

11. Explica al usuario los tres pasos humanos que faltan: aprobar el PR de release, fusionarlo (el pipeline crea la etiqueta `v<version>`), y aprobar el environment `prod` en la pestaña Actions cuando el job lo pida. Tú no lanzas workflows ni publicas etiquetas.
12. Después del despliegue, sigue el plan de observación con `/asistentic:verificar-release v<version>`; si se supera un umbral, `/asistentic:rollback v<version>`.
