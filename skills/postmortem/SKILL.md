---
name: postmortem
description: Cierra un incidente de producción con una cronología, causa raíz y la regla nueva que lo habría evitado
argument-hint: "[JIRA-123]"
disable-model-invocation: true
---

Vas a redactar el postmortem del incidente $ARGUMENTS. Es un postmortem sin culpables: describe sistemas y procesos, nunca personas.

1. Reúne: ticket del incidente, fix aplicado, logs, PRs involucrados y, si existe, `docs/fixes/$ARGUMENTS.md`.
2. Escribe `docs/postmortems/$ARGUMENTS.md`:

```markdown
# Postmortem $ARGUMENTS — <título>

## Impacto
Qué dejó de funcionar, para quién, durante cuánto tiempo.

## Cronología
Hora a hora: detección, diagnóstico, corrección, verificación.

## Causa raíz
Qué pasó y por qué el sistema lo permitió.

## Qué funcionó
Qué parte del proceso ayudó a detectarlo o corregirlo rápido.

## Qué regla lo habría evitado
UNA sola acción concreta: una regla nueva en el plugin, un test, un check en el pipeline o un cambio de política de datos. Con el texto exacto de la regla propuesta.

## Seguimiento
- [ ] PR al plugin o al pipeline con la regla nueva
- [ ] Verificar en el próximo ciclo que la regla se aplica
```

3. Abre un PR al repositorio del plugin con la regla propuesta, o explica al usuario cómo hacerlo si no tienes acceso. Si la regla puede verificarse de forma determinista (un patrón, un comando, un nombre de archivo), propón también un hook y su prueba en `evals/hooks/probar-hooks.sh`; si requiere criterio, propón un caso en `evals/` con un fixture que reproduzca el error y un grader que exija detectarlo. Una regla sin caso de eval se pierde en la siguiente edición del plugin.
4. Resume el postmortem en cinco líneas para compartir en la retro mensual.
