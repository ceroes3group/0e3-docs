# Reporte — Fase B0–B5 (Preparación Billing Core)

**Fecha:** 2026-05-27  
**Decisiones oficiales heredadas de Fase N:** ownership map ✅, estructura ecosistema ✅, Billing Core = iniciativa principal ✅, Support Core diferido ✅, no producción ✅

---

## Resumen ejecutivo

Se completó la **preparación documental** para implementar 0E3 Billing Core reutilizando la experiencia madura del billing POS en producción. **No se escribió código**, no se creó repo GitHub, no se tocó Firebase/MP/prod.

---

## B0 — Repositorio conceptual `0e3-billing`

| Item | Estado |
|---|---|
| GitHub `ceroes3group/0e3-billing` | ❌ No existe |
| Blueprint documentado | ✅ [`0e3-billing-repo-blueprint.md`](../billing/0e3-billing-repo-blueprint.md) |
| Código | ⏸ Pendiente aprobación humana post-Fase B |

**Estructura futura:** `packages/billing-contracts`, `packages/billing-adapters`, `functions/`, Firebase sandbox `oe3-billing-sandbox`.

---

## B1 — Auditoría profunda POS

**Proyecto auditado:** `nexopos-dc-multi-tenant`

### Hallazgos clave

| Componente | Ubicación | Veredicto |
|---|---|---|
| Núcleo MP (webhook, checkout, preapproval) | `billing-mercadopago.routes.js` (~800 LOC) | **→ Billing Core** |
| Idempotencia | `billingMercadoPago/pay_{id}` | **→ billingWebhooks** |
| Extensión 30 días | `extendLicenseAfterPayment()` | **→ subscriptionService** |
| Middleware licencia | `checkLicense()` + `licenseHelpers.js` | **Abstraer** → EntitlementService; reglas `/ventas` quedan POS |
| Onboarding kit 2×$250k | `onboardingBilling.js` | **Adapter** POS-specific |
| Admin precios | `/admin/platform/billing` | **→ Plan Catalog Core** |
| Frontend | `billing.service.js`, `billingOnboarding.js` | Contrato `getPlans()` |
| Cron billing | ❌ **No existe** — evaluación lazy en request | Core puede agregar job opcional |
| `subscriptionAccess.js` | Límites usuarios/sesiones | **Permanece POS** — lee `features` |

**Documento:** [`0e3-pos-billing-extraction-plan.md`](../billing/0e3-pos-billing-extraction-plan.md)

---

## B2 — Contratos compartidos

Definidos 5 colecciones con interfaces TypeScript, validaciones e índices:

| Colección | Doc ID pattern | Rol |
|---|---|---|
| `billingPlans` | `{productId}_{planId}` | Catálogo precios |
| `billingSubscriptions` | auto / `{tenantId}_{productId}` | Suscripción activa |
| `tenantEntitlements` | `{tenantId}_{productId}` | Consulta rápida apps |
| `billingWebhooks` | `{provider}_{eventId}` | Idempotencia IPN |
| `billingEvents` | auto | Auditoría + shadow |

**Documento:** [`0e3-billing-contracts.md`](../billing/0e3-billing-contracts.md)

---

## B3 — Shadow Mode

Estrategia **sin impacto clientes**:

- **Modo B recomendado:** scheduled diff cada 15 min (read-only legacy vs Core sandbox)
- **Modo A opcional:** replay webhook en sandbox
- **Modo C:** inline read staging only
- SLA: match rate ≥ 99.5% antes de dual-write
- Rollback: inherentemente seguro (shadow no escribe prod)

**Documento:** [`0e3-shadow-mode-plan.md`](../billing/0e3-shadow-mode-plan.md)

---

## B4 — Migración POS (5 fases)

| Fase | Nombre | Prod impact |
|---|---|---|
| 1 | Sandbox | ❌ Ninguno |
| 2 | Shadow Read | ❌ Ninguno |
| 3 | Dual Write | ⚠️ Flag; legacy primary |
| 4 | Cutover | 🔴 Ventana planificada |
| 5 | Legacy Read-Only | Archivo histórico |

**Documento:** [`0e3-pos-migration-plan.md`](../billing/0e3-pos-migration-plan.md)

---

## B5 — Registro de riesgos

| Prioridad | Count | Top riesgos |
|---|---|---|
| **P1** | 8 | Desync dual-write, webhook URL, cliente sin extensión, super admin bypass |
| **P2** | 17 | MP idempotencia, gracia 24h, rollback cutover |
| **P3–P4** | 11 | Performance shadow, demos, timezone false positives |

**Documento:** [`0e3-billing-risk-register.md`](../billing/0e3-billing-risk-register.md)

---

## Documentos generados (Fase B)

| Fase | Documento |
|---|---|
| B0 | `billing/0e3-billing-repo-blueprint.md` |
| B1 | `billing/0e3-pos-billing-extraction-plan.md` |
| B2 | `billing/0e3-billing-contracts.md` |
| B3 | `billing/0e3-shadow-mode-plan.md` |
| B4 | `billing/0e3-pos-migration-plan.md` |
| B5 | `billing/0e3-billing-risk-register.md` |
| — | `reports/FASE-B-BILLING-PREPARATION-REPORTE.md` (este) |

---

## Restricciones respetadas

- ❌ Deploy
- ❌ Producción
- ❌ MercadoPago real
- ❌ Gastro / OTA
- ❌ Billing live
- ❌ Firebase rules
- ❌ Cloudflare
- ✅ Documentación, contratos, diseño, auditoría POS

---

## Recomendación — próximos pasos (post-aprobación humana)

| # | Acción | Tipo |
|---|---|---|
| 1 | **Aprobación humana** de este reporte + contratos | Decisión |
| 2 | Crear repo GitHub `ceroes3group/0e3-billing` (privado) | GitHub admin |
| 3 | Crear Firebase `oe3-billing-sandbox` | Infra sandbox |
| 4 | Fase 1 Sandbox: `billing-contracts` + webhook MP test | Código |
| 5 | Export manual `platform/billing` → seed `billingPlans` | Ops |
| 6 | Shadow en POS **staging** (Modo B) | Integración |
| 7 | Support Core | ⏸ Diferido post-Billing Fase 2 |

---

## Índice billing completo

| Documento | Fase |
|---|---|
| [0e3-billing-current-audit.md](../billing/0e3-billing-current-audit.md) | Pre-B |
| [0e3-billing-core-spec.md](../billing/0e3-billing-core-spec.md) | Pre-B |
| [mercadopago-integration-plan.md](../billing/mercadopago-integration-plan.md) | Pre-B |
| [0e3-entitlements-access-control.md](../billing/0e3-entitlements-access-control.md) | Pre-B |
| [0e3-billing-rollout-plan.md](../billing/0e3-billing-rollout-plan.md) | Pre-B |
| [0e3-billing-gap-analysis.md](../billing/0e3-billing-gap-analysis.md) | N |
| [0e3-billing-repo-blueprint.md](../billing/0e3-billing-repo-blueprint.md) | B0 |
| [0e3-pos-billing-extraction-plan.md](../billing/0e3-pos-billing-extraction-plan.md) | B1 |
| [0e3-billing-contracts.md](../billing/0e3-billing-contracts.md) | B2 |
| [0e3-shadow-mode-plan.md](../billing/0e3-shadow-mode-plan.md) | B3 |
| [0e3-pos-migration-plan.md](../billing/0e3-pos-migration-plan.md) | B4 |
| [0e3-billing-risk-register.md](../billing/0e3-billing-risk-register.md) | B5 |

---

⏸ **Esperando aprobación humana antes de escribir código.**
