---
name: spec
description: Redacta la especificación técnica de un ticket de Jira antes de codificar, leyendo el código real del proyecto
argument-hint: "[JIRA-123]"
disable-model-invocation: true
---

Vas a redactar la especificación técnica del ticket $ARGUMENTS. No escribas código todavía.

Pasos:

1. Lee el ticket. Si hay un servidor MCP de Jira conectado, úsalo; si no, pide al usuario que pegue el título, la descripción y los criterios de aceptación.
2. Lee `CLAUDE.md` y `asistentic.yaml` del repositorio para conocer la arquitectura, los ambientes y los componentes del proyecto.
3. Explora el código que el cambio tocaría. Busca los módulos, tablas, stored procedures y pantallas relacionados. Cita archivos con su ruta.
4. Escribe la spec en `docs/specs/$ARGUMENTS.md` con esta estructura exacta:

```markdown
# $ARGUMENTS — <título del ticket>

## Qué cambia
Una o dos frases en lenguaje de negocio.

## Componentes afectados
Lista de repositorios y módulos. Si el proyecto tiene varios repositorios, indica qué cambia en cada uno.

## Cambios de base de datos
Tablas, columnas, stored procedures. Si hay tabla nueva, incluye su política de datos (clave de partición, días en caliente, retención). Si no hay cambios, escribe "Ninguno".

## Riesgos
Qué puede romperse, qué datos sensibles se tocan, qué depende de terceros.

## Criterios de aceptación verificables
Uno por línea, cada uno comprobable en QA.

## Métricas afectadas o nuevas
Qué métrica del catálogo cambia o debería crearse.

## Estimación
Pequeña (< 1 día), Mediana (1 a 3 días) o Grande (> 3 días), con una frase de justificación.

## Preguntas abiertas
Lo que el tech lead o el product owner deben aclarar antes de implementar.
```

5. Termina con un resumen de cinco líneas para el ticket y recuérdale al usuario que la spec necesita aprobación del tech lead antes de correr `/asistentic:implementar`.

Reglas:
- No inventes comportamiento del sistema; si no está en el código ni en el ticket, va en "Preguntas abiertas".
- Si el ticket toca cálculo de premios, pagos, saldos o datos personales, márcalo en Riesgos con la palabra SENSIBLE en mayúsculas.
