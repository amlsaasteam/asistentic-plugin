#!/usr/bin/env bash
# Copia el fixture al directorio de trabajo del caso y crea el historial git con una rama de PR.
set -e
FIX="$(dirname "$0")/repo-dotnet"
cp -r "$FIX"/. .
git init -q && git config user.email eval@asistentic && git config user.name eval
git add . && git commit -qm "chore: fixture"
git checkout -qb feature/LOT-900
echo "// cambio LOT-900" >> src/Ventas/AnularVentaHandler.cs
git commit -qam "LOT-900: anular venta"
