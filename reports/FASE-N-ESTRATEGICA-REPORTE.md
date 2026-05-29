# Reporte — Fase N estratégica (N1–N5)

**Fecha:** 2026-05-27  
**Alcance:** documentación, Git, arquitectura — sin código ni producción

---

## A) Push realizados

### 1. `0e3-docs` ✅

| Item | Valor |
|---|---|
| Branch | `main` |
| Comando | `git push origin main` |
| Rango | `5f70342..f7cd429` |
| Hash final GitHub | `f7cd4294b3abf98ddb5ae2bf7501789dd1ac4c2b` |
| Working tree | ✅ Limpio |
| Sync | `main...origin/main` |

**Incluye:** consolidación ecosistema, arquitectura N2–N5 (commits posteriores pendientes push si se commitean ahora).

### 2. Gastro — `docs/GIT-REMOTE-ALIGNMENT.md` ✅

| Item | Valor |
|---|---|
| Método | Cherry-pick `01e14d8` sobre `origin/chore/oe3-architecture` |
| Hash GitHub | `8f57c9a2f382fe85b61f6187d4ec65dcae36c22a` |
| Branch remoto | `chore/oe3-architecture` |
| Archivo | `docs/GIT-REMOTE-ALIGNMENT.md` |

**No se tocó:** OTA, billing, MP, Firebase, código productivo.

**Nota:** push directo local rechazado (non-fast-forward). Solo doc integrado sobre base remota.

### 3. Aliados — ❌ NO push (por instrucción)

---

## B) Estado Git final

| Repo | Branch | Remote hash | Local hash | Sync | Working tree |
|---|---|---|---|---|---|
| **0e3-docs** | `main` | `f7cd429` | `f7cd429`* | ✅ | Limpio |
| **0e3-gastro** | `chore/oe3-architecture` | `8f57c9a` | `01e14d8` | ⚠️ Divergente | Limpio |
| **0e3-aliados** | `chore/oe3-architecture` | `71a206e` | `ebe4f44` | ⚠️ Ahead 1 + WIP | ⚠️ Muchos cambios |
| **0e3-home** | `chore/oe3-architecture` | `000fba1` | `000fba1` | ✅ | Limpio |
| **0e3-landing** | `main` | `8fecdd3` | `8fecdd3` | ✅ | Limpio |

\* Tras commit N2–N5 local, docs estará ahead 1 hasta próximo push.

### Gastro — backup local

Branch `backup/local-chore-oe3-architecture` creada apuntando a historial local completo.

---

## C) Naming conflicts encontrados

| Conflicto | Severidad | Detalle |
|---|---|---|
| **`0e3-home` = Flutter app, no portal** | 🔴 Crítica | Repo name vs producto vs expectativa dev |
| **Apex `0e3.com.ar` vs `0es3.com.ar`** | 🟡 Media | Transición DNS pendiente |
| **POS en org externa** | 🟡 Media | `danielcadiz15` vs `ceroes3group` |
| **Gastro Git divergente** | 🟡 Media | Local commits ≠ remoto squash |
| **Site Firebase `0es3-com-ar`** | 🟢 Baja | ID histórico vs dominio objetivo |

Detalle: [`architecture/0e3-product-ownership-map.md`](../architecture/0e3-product-ownership-map.md)

---

## D) Estructura final recomendada

| Repo | Dominio |
|---|---|
| `0e3-landing` | `0es3.com.ar` (portal) |
| `0e3-pos` | `pos.0es3.com.ar` |
| `0e3-gastro` | `gastro.0es3.com.ar` |
| `0e3-home-app` | `home.0es3.com.ar` |
| `0e3-aliados-comerciales` | `aliados.0es3.com.ar` |
| `0e3-docs` | `docs.0es3.com.ar` |
| `0e3-billing` (futuro) | `billing.0es3.com.ar` |
| `0e3-support` (futuro) | `support.0es3.com.ar` |

Detalle: [`architecture/0e3-final-ecosystem-structure.md`](../architecture/0e3-final-ecosystem-structure.md)

---

## E) Riesgos

| Riesgo | Prioridad |
|---|---|
| Renombrar `0e3-home` rompe clones/CI | 🟡 |
| Migración POS a org central | 🔴 |
| Gastro OTA/billing al implementar Billing Core | 🔴 |
| Push Aliados WIP sin review seguridad | 🟡 |
| Confusión apex durante cutover DNS | 🟡 |

---

## F) Recomendación — arrancar Billing Core

1. **Aprobar formalmente** naming + ownership map (este informe).
2. **Crear repo vacío** `ceroes3group/0e3-billing` (solo docs + schema).
3. **Implementar en sandbox** Firestore schema (`billingPlans`, `tenantEntitlements`, …).
4. **Primer adapter:** Gastro **staging** shadow-read (sin dual-write prod).
5. **POS prod:** solo después de Gastro staging validado + ventana planificada.

Gap analysis: [`billing/0e3-billing-gap-analysis.md`](../billing/0e3-billing-gap-analysis.md)

**NO tocar:** `billing-mercadopago.routes.js` prod, Gastro webhook staging, MP credentials prod.

---

## G) Recomendación — arrancar Support Core

1. **Después de** naming resuelto (evitar repo mal nombrado).
2. **Crear repo** `0e3-support` con schema tickets Firestore.
3. **MVP:** `createTicket` callable + panel React agentes.
4. **Primer integrador:** Aliados (bajo riesgo, panel ya existe).
5. **Packages:** `@0e3/support-client` (React) luego `0e3_support` (Dart).

Gap analysis: [`support-core/0e3-support-gap-analysis.md`](../support-core/0e3-support-gap-analysis.md)

---

## H) Próxima fase sugerida — Fase N+1

| Orden | Tarea | Tipo |
|---|---|---|
| 1 | **Aprobación humana** naming + estructura final | Decisión |
| 2 | Push docs N2–N5 (`architecture/`, gap analyses) | Git |
| 3 | Renombrar GitHub `0e3-home` → `0e3-home-app` | GitHub admin |
| 4 | Crear ramas `develop` en repos producto | Git |
| 5 | Aliados: estabilizar WIP → PR → push | Git |
| 6 | Alinear Gastro local con remoto (opción A/B en GIT-REMOTE-ALIGNMENT) | Git |
| 7 | Crear repos vacíos `0e3-billing`, `0e3-support` | GitHub |
| 8 | Iniciar Billing Core sandbox (código — nueva fase) | Dev |

---

## Documentos generados (Fase N)

| Documento | Ruta |
|---|---|
| Product ownership map | `architecture/0e3-product-ownership-map.md` |
| Estructura final | `architecture/0e3-final-ecosystem-structure.md` |
| Billing gap analysis | `billing/0e3-billing-gap-analysis.md` |
| Support gap analysis | `support-core/0e3-support-gap-analysis.md |
| Este reporte | `reports/FASE-N-ESTRATEGICA-REPORTE.md` |

---

⏸ Sin deploy. Sin Firebase/Cloudflare/MP/OTA/billing prod.
