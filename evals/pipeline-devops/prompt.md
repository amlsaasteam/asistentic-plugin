---
max_turns: 30
allowed_tools: [Read, Glob, Grep, Bash, Edit, Write, Agent, Skill]
scaffold_script: ../fixtures/scaffold-dotnet.sh
tags: [devops, pipeline]
---

Estás en el repositorio Lotobet (API .NET, SQL Server, se despliega a ECS en us-east-1 con migraciones DbUp). No hay `gh`: en lugar de abrir el PR, deja los archivos en la rama `chore/pipeline-asistentic` y describe en tu respuesta final qué generaste y qué debe configurarse fuera del repositorio. Asume los valores de `despliegue` propuestos sin preguntar.

Corre `/asistentic:pipeline crear`.
