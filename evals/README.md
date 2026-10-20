# Evals del plugin Asistentic

Dos niveles:

1. **Hooks (deterministas, sin modelo):** `bash evals/hooks/probar-hooks.sh`. Corre en segundos; va en el CI del repositorio del plugin en cada PR.
2. **Skills y agentes (con modelo):** `claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Edit Write Agent --threshold 0.8`. Cuesta tokens (usa `--runs 1` para probar rápido y `--max-cost-usd 2` como techo). Corre antes de publicar una versión nueva del plugin al marketplace.

| Caso | Qué protege |
| --- | --- |
| `revisar-secreto-en-diff` | `/revisar` detecta secreto, SQL concatenado, fallo silencioso, migración mala y test vacío; no aprueba |
| `desarrollar-cambio-pequeno` | `/desarrollar` trabaja en rama con ticket, test primero, sin secretos nuevos |
| `validar-migracion-sin-particion` | `validador-sql` detecta motor y bloquea tabla sin PK, FLOAT y sin partición |
| `mongodb-saldos` | `validador-mongodb` bloquea dinero en documentos, double, arrays sin tope e inyección |
| `revisar-sin-tests` | `analista-tests` cruza criterios de la spec con tests y detecta tests vacíos |
| `pipeline-devops` | `/pipeline` + agente `devops` generan ci/cd con OIDC, QA automático, prod con aprobación, migraciones y humo |

El fixture `fixtures/repo-dotnet` tiene defectos a propósito (credenciales falsas, SQL concatenado, catch vacío, migración sin PK). No lo uses como plantilla de nada.

Cuando un postmortem agregue una regla nueva a `reglas/`, agrega aquí un caso que la ejercite: así la regla no se pierde en la siguiente edición del plugin.
