# Reglas .NET / C#

Aplican a todo repositorio con proyectos `.csproj`.

## Estructura
- Capas separadas: API o UI, Aplicación (casos de uso), Dominio, Infraestructura (acceso a datos, servicios externos). Nada de SQL en controladores ni en la UI.
- Un caso de uso por clase; nombre en verbo: `AprobarPrestamo`, `RegistrarVenta`.

## Acceso a datos
- Siempre consultas parametrizadas. Nunca concatenar strings en SQL.
- Las cadenas de conexión vienen de configuración por ambiente o de la bóveda; nunca en código ni en `appsettings.json` del repositorio.
- Toda tabla transaccional se consulta a través de la librería de acceso de Asistentic, que resuelve el nivel (caliente, tibio, frío) por rango de fechas.

## Errores y logs
- Excepciones de dominio propias; no atrapar `Exception` genérica salvo en el borde (middleware).
- Logs estructurados (Serilog o `ILogger` con plantillas). Nunca registrar cédulas, cuentas, tarjetas ni montos de clientes finales.

## Pruebas
- xUnit o NUnit. Un test por criterio de aceptación de la spec, nombrado `Deberia_<resultado>_Cuando_<condicion>`.
- Las pruebas de acceso a datos corren contra una base de QA o un contenedor; nunca contra producción.

## Estilo
- `async`/`await` de punta a punta; nada de `.Result` ni `.Wait()`.
- Nullable habilitado; sin warnings de nulabilidad en código nuevo.
- `dotnet format` limpio antes de cada commit.
