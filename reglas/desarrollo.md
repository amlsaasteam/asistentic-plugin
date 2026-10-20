# Reglas generales de desarrollo

Aplican a todo repositorio, en cualquier stack. Las reglas por stack (`dotnet.md`, `java.md`) y por motor de datos (`sqlserver.md`, `oracle.md`, `aurora.md`, `mongodb.md`) las complementan; nunca las contradicen.

## Diseño
- Una responsabilidad por clase o módulo; un caso de uso por clase, nombrado en verbo (`AprobarPrestamo`, `RegistrarVenta`).
- Dependencias hacia adentro: la lógica de negocio no conoce el framework web, el ORM ni el proveedor de nube.
- Nada de lógica de negocio en controladores, handlers, triggers ni stored procedures nuevos. Los SP existentes se mantienen; los nuevos requieren justificación en la spec.
- Preferir composición y funciones pequeñas a herencia profunda. Máximo 60 líneas por función; si pasa, se divide.
- No abstraer antes de la segunda repetición real. Nada de capas "por si acaso".

## Nombres y legibilidad
- Nombres que dicen qué hacen, en el idioma del dominio del proyecto (español o inglés, pero uno solo por repositorio, el que ya domine).
- Sin comentarios que repiten el código. Sí comentarios que explican un porqué no evidente (regulación, límite de un proveedor, decisión de negocio).
- Números y cadenas mágicas en constantes con nombre.

## Errores
- Excepciones propias del dominio con mensajes para el desarrollador, no para el usuario final.
- Atrapar `Exception` genérica solo en el borde (middleware, handler global, punto de entrada de un batch).
- Nunca tragar una excepción en silencio. Si se ignora, se registra con nivel `Warning` y la razón.
- Validar entradas en el borde una vez; no re-validar en cada capa.

## Seguridad (OWASP, lo mínimo)
- Toda consulta parametrizada. Nunca concatenar entradas del usuario en SQL, filtros de MongoDB, comandos de shell ni rutas de archivo.
- Secretos y cadenas de conexión en la bóveda o en variables de entorno del ambiente; nunca en el repositorio, ni en archivos de configuración versionados, ni en tests.
- Autorización en cada caso de uso, no solo en el menú o en la UI.
- Datos personales y financieros (cédula, cuenta, tarjeta, saldo, monto de cliente final) nunca en logs, mensajes de error ni URLs.
- Dependencias con vulnerabilidades conocidas se actualizan en el mismo PR que las detecta o se abre un ticket con fecha.

## Pruebas
- Pirámide: muchas unitarias, algunas de integración, pocas de extremo a extremo.
- Un test por criterio de aceptación de la spec; nombre `Deberia_<resultado>_Cuando_<condicion>` (o la convención del stack).
- Los tests no dependen del orden ni de datos que otro test dejó. Cada test prepara y limpia lo suyo.
- Pruebas de acceso a datos contra QA o un contenedor; nunca contra producción.
- Un bug corregido deja un test que lo reproduce antes del arreglo.

## Configuración y ambientes
- Un solo binario o imagen para todos los ambientes; lo que cambia es configuración, no código.
- Comportamiento por ambiente mediante configuración declarada, nunca `if (ambiente == "prod")`.
- Feature flags para cambios que se despliegan antes de activarse.

## Logs y observabilidad
- Logs estructurados (JSON o plantillas), con `correlation id` por petición o por corrida de batch.
- Nivel `Information` para eventos de negocio, `Warning` para lo recuperable, `Error` para lo que requiere acción.
- Toda tabla o flujo de negocio nuevo declara su métrica en `metricas.yaml` o justifica por qué no.

## API
- REST: sustantivos en plural, verbos HTTP correctos, códigos de estado reales (no `200` con `{"error": ...}`).
- Versionado desde el primer día (`/v1/`). Un contrato publicado no se rompe; se agrega otra versión.
- Paginación obligatoria en cualquier lista que pueda crecer.
- Idempotencia en operaciones que mueven dinero o crean registros desde clientes externos (clave de idempotencia).

## Rendimiento
- Sin consultas dentro de bucles (N+1). Cargar en conjunto.
- Operaciones sobre tablas transaccionales siempre acotadas por rango de fecha y a través de la librería de acceso de Asistentic.
- Trabajo largo (reportes, cierres, conciliaciones) fuera de la petición HTTP: cola o batch.

## Git
- Rama por ticket (`feature/TICKET-123`, `fix/TICKET-456`), PR pequeño (ideal menos de 400 líneas), un tema por PR.
- Commits con prefijo del ticket y frase en imperativo.
- Nunca push directo a `main`. Nunca fuerza (`--force`) sobre ramas compartidas.
- Formateador del stack limpio antes de cada commit.
