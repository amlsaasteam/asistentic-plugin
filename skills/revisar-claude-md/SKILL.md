---
name: revisar-claude-md
description: Al final de una sesión de trabajo, propone qué agregar, corregir o quitar en CLAUDE.md a partir de lo que el agente tuvo que descubrir por su cuenta. Mantiene el archivo corto y útil.
disable-model-invocation: true
---

Vas a revisar el `CLAUDE.md` de este repositorio con base en lo que pasó en esta sesión. No cambies código.

1. Lee el `CLAUDE.md` actual y cuenta sus líneas.
2. Repasa la sesión y anota:
   - **Lo que tuviste que descubrir** leyendo código o preguntando, y que un `CLAUDE.md` debió decirte: un comando de build distinto, una convención de nombres, una carpeta de migraciones, un servicio que siempre hay que levantar, una zona sensible no listada.
   - **Lo que el archivo dice y resultó falso o desactualizado** (un comando que ya no existe, una ruta que cambió).
   - **Lo que el archivo dice y nunca hizo falta** o que el código ya deja claro por sí solo.
   - **Instrucciones que ignoraste o malinterpretaste** más de una vez: probablemente están mal redactadas o enterradas.
3. Propón cambios concretos, cada uno de una línea, en tres listas: Agregar, Corregir, Quitar. Para cada uno, una frase de por qué. Aplica el criterio de Anthropic: si quitar la línea no haría que un agente se equivoque, no va. Nada de explicaciones largas, nada que el código ya diga, nada que cambie cada semana.
4. Respeta el límite: el archivo resultante no supera 80 líneas. Si agregar algo lo supera, hay que quitar algo primero.
5. Muestra la propuesta y espera aprobación del usuario. Solo entonces edita `CLAUDE.md` y haz un commit `chore: actualizar CLAUDE.md` en una rama `chore/claude-md-<fecha>`, con PR para el tech lead.

Si algo descubierto es una regla que aplica a todos los repositorios (no solo a este), no va en `CLAUDE.md`: propón un PR a `reglas/` del plugin Asistentic y dilo explícitamente.
