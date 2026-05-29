# Plan migración Node.js 20 → 22

**Estado:** Documentación — **no ejecutar** sin aprobación  
**Fecha:** 2026-05-27

---

## Inventario actual

| Proyecto | Archivo | `engines.node` | CI Node |
|---|---|---|---|
| **landing** | `package.json` | *(sin engines)* | 20 (template workspace) |
| **aliados root** | `package.json` | `>=20` | — |
| **aliados functions** | `functions/package.json` | `20` | — |
| **aliados web/shared** | — | sin engines | — |
| **gastro functions** | `functions/package.json` | `22` | — |
| **POS functions** | `nexopos-dc/functions/package.json` | `22` | — |
| **oe3_home** | Flutter | N/A | N/A |

---

## Objetivo

Unificar en **Node 22 LTS** para:
- Functions Firebase (Gen2)
- CI GitHub Actions
- Builds web (Next/Vite)

---

## Orden de migración propuesto

| Fase | Repo | Riesgo | Acción |
|---|---|---|---|
| 1 | `0e3-docs` | 🟢 | CI Node 22 en template |
| 2 | `0e3-landing` | 🟢 | Agregar `"engines": { "node": ">=22" }`, probar build |
| 3 | `0e3-aliados` functions | 🟡 | Bump engines 20→22, `npm test` |
| 4 | `0e3-gastro` functions | 🟢 | Ya en 22 — validar deploy staging |
| 5 | `nexopos-dc` | 🔴 | Ventana planificada — prod activo |

---

## Checklist por repo (cuando se apruebe)

```powershell
# Local con nvm/fnm
nvm install 22
nvm use 22
node -v   # v22.x

npm ci
npm run build
npm test
firebase emulators:start   # smoke test functions
```

---

## Cambios esperados en archivos

```json
// package.json
"engines": {
  "node": ">=22"
}
```

```yaml
# .github/workflows/*.yml
- uses: actions/setup-node@v4
  with:
    node-version: "22"
```

---

## Riesgos

| Riesgo | Mitigación |
|---|---|
| Breaking changes Node 22 en deps viejas | `npm outdated`, bump lockfile |
| Cloud Functions runtime | Verificar runtime `nodejs22` en Firebase |
| POS prod | Migrar último, con rollback |

---

## Compatibilidad Firebase Functions

Verificar en Firebase Console que el runtime soporta `nodejs22` para cada proyecto antes de deploy.

---

## Referencias

- CI estándar: [`ci-cd-standard.md`](ci-cd-standard.md)
- Deploy: [`../deploy.md`](../deploy.md)
