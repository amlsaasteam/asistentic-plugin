# Reglas Java

Aplican a repositorios con `pom.xml` o `build.gradle`.

- Capas separadas: controlador, servicio (casos de uso), dominio, repositorio. Sin SQL en controladores.
- JDBC o JPA siempre con parámetros; nunca concatenar SQL.
- Configuración por ambiente fuera del repositorio; secretos en la bóveda.
- Excepciones de dominio propias; `catch (Exception e)` solo en el borde.
- Logs con SLF4J y plantillas; sin datos personales ni financieros de clientes finales.
- JUnit 5; un test por criterio de aceptación, nombrado `deberia_<resultado>_cuando_<condicion>`.
- Formato con `spotless` o `google-java-format` limpio antes de cada commit.
- Acceso a tablas transaccionales a través de la librería de acceso de Asistentic.
