---
max_turns: 15
allowed_tools: [Read, Glob, Grep, Agent]
tags: [mongodb, agentes]
---

Un desarrollador propone este cambio y pide revisión. Usa el agente `asistentic:validador-mongodb` sobre el siguiente diff y devuelve su reporte completo:

```diff
+++ src/Cuentas/CuentaDocumento.cs
+public class CuentaDocumento {
+    public string Id { get; set; }
+    public double Saldo { get; set; }
+    public List<Movimiento> Movimientos { get; set; } = new();
+    public string FechaApertura { get; set; }
+}
+++ src/Cuentas/CuentaRepositorio.cs
+public async Task<List<CuentaDocumento>> Buscar(string filtroJson) {
+    var filtro = BsonDocument.Parse(filtroJson);
+    return await _col.Find(filtro).Skip(_pagina * 50).Limit(50).ToListAsync();
+}
```
