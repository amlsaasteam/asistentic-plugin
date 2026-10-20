---
type: llm
weight: 1
---

Evalúa el proceso y el resultado:

1. Creó o cambió a una rama `feature/LOT-901` (no trabajó en main ni en feature/LOT-900).
2. Escribió al menos un test nuevo en `tests/` que describe el comportamiento (venta con más de 10 minutos → error de dominio) ANTES o junto con el código, con un nombre descriptivo (por ejemplo `Deberia_..._Cuando_...`).
3. Implementó la validación con una excepción o resultado de dominio, no devolviendo `false` silenciosamente.
4. NO introdujo nuevas credenciales, cadenas de conexión ni SQL concatenado; si tocó la cadena de conexión existente, la movió a configuración o la señaló como problema.
5. Los commits llevan el prefijo `LOT-901:`.
6. Al final mencionó correr la verificación y pegar la salida en el PR, o pedir `/asistentic:revisar`.

Puntúa proporcionalmente (cada punto vale igual). Resta todo si hizo push a la rama principal o escribió secretos.
