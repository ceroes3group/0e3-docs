# Billing Core — Análisis de brechas (gap analysis)

**Versión:** 1.0  
**Fecha:** 2026-05-27  
**Estado:** Preparación — **sin implementación**

Base: revisión de `billing/0e3-billing-*.md`, `mercadopago-integration-plan.md`, `0e3-entitlements-access-control.md`, `0e3-billing-rollout-plan.md`

---

## 1. Qué partes de POS pueden reutilizarse

| Componente POS | Ubicación | Reutilización en Billing Core |
|---|---|---|
| Webhook + confirmación GET `/v1/payments/:id` | `billing-mercadopago.routes.js` | ✅ Patrón idéntico |
| Idempotencia `billingMercadoPago/pay_{id}` | Firestore | ✅ Modelo → `billingWebhooks` |
| Preapproval + Checkout Pro | Misma route | ✅ API unificada |
| `platform/billing.planPrices` | Firestore | ✅ Seed → `billingPlans` |
| Onboarding kit 2×$250k | `onboardingBilling.js` | ⚠️ Adapter POS-specific |
| Admin precios por plan | `/admin/platform/billing` | ✅ Panel admin Core |
| `getBillingPublicConfig()` | Frontend service | ✅ Contrato `getPlans()` |
| Extensión `paidUntil` +30 días | `extendLicenseAfterPayment` | ✅ → `activeUntil` |
| Secret `MERCADOPAGO_ACCESS_TOKEN` | Secret Manager | ✅ Unificar naming |
| Docs operativas | `docs/billing-mercadopago.md` | ✅ Runbook |

---

## 2. Qué partes NO deben tocarse (sin ventana planificada)

| Área | Motivo |
|---|---|
| `billing-mercadopago.routes.js` en **prod** | Clientes pagando hoy |
| Webhook URL registrada en MP **prod** | Cobros activos |
| `platform/billing` Firestore prod | Precios live |
| Middleware licencia `functions/index.js` | Bloqueo sesiones prod |
| Flujo `onboarding_v2` | Kit comercial activo |
| Gastro `mercadoPagoWebhook` staging | OTA + tablets |
| Gastro `firebase.gastro-only.json` rewrites | APK/billing site |
| Gastro `functions/.env.e3-gastro-staging` | MP_BACK_URL live |
| `contract.ts` provisioning intents | Checkout base plan staging |

**Estrategia:** dual-write + feature flag `billingCoreEnabled` — nunca big-bang.

---

## 3. Adapters requeridos

### 3.1 Identidad tenant

| Legacy | Billing Core | Adapter |
|---|---|---|
| POS `orgId` | `tenantId` | `tenantId = orgId` (1:1 inicial) |
| Gastro `tenantId` | `tenantId` | Directo |
| HOME user/family | `tenantId` | **Nuevo** — definir entidad billing |
| Aliados org | `tenantId` | **Nuevo** — panel aliado |

### 3.2 Vigencia licencia

| Legacy | Billing Core | Transformación |
|---|---|---|
| POS `paidUntil` (ISO string) | `activeUntil` (Timestamp) | Parse ISO → Timestamp |
| Gastro `licenseEndsAt` | `activeUntil` | Directo |
| Gastro `trialEndsAt` | `trialEndsAt` | Directo |
| POS `blocked` | `tenantEntitlements.blocked` | Boolean map |
| Gastro `licenseStatus` | `status` enum | Map: `active`→active, `trial`→trial, `expired`→expired |

### 3.3 MercadoPago external_reference

| Legacy | Core propuesto |
|---|---|
| POS `orgId` en metadata/external_reference | `{tenantId}:{productId}:{planId}:{intentId}` |
| Gastro `tenantId:plan` | Mismo formato extendido |

### 3.4 Planes

| POS | Gastro | Core `planId` |
|---|---|---|
| `basic`, `intermediate`, `premium` | `base`, `premium` | Catálogo por `productId` — no unificar nombres cross-product |

---

## 4. Colecciones Firestore a mantener (legacy)

Durante migración **dual-write**, no eliminar:

### POS

| Colección | Mantener hasta |
|---|---|
| `companies/{orgId}/config/license` | Cutover POS completo |
| `licenses/{orgId}` | Cutover POS completo |
| `platform/billing` | Migrado a `billingPlans` |
| `billingMercadoPago/*` | Histórico + idempotencia legacy |

### Gastro

| Colección | Mantener hasta |
|---|---|
| `tenants/{id}` campos licencia | Cutover Gastro |
| `tenants/{id}/billingPayments` | Histórico |
| `tenants/{id}/billingEvents` | Histórico |
| `subscriptionIntents/*` | Flujo contract activo |

---

## 5. Colecciones nuevas (Billing Core)

| Colección | Propósito | Prioridad |
|---|---|---|
| `billingPlans` | Catálogo planes por producto | P0 |
| `billingSubscriptions` | Suscripción activa/histórica | P0 |
| `tenantEntitlements` | Vista materializada consulta rápida | P0 |
| `billingWebhooks` | Payload crudo MP + idempotencia | P0 |
| `billingPayments` | Pagos individuales | P1 |
| `billingEvents` | Auditoría dominio | P1 |
| `billingInvoices` | Reporting períodos | P2 |

**Ubicación Firebase:** proyecto dedicado `0e3-billing` (recomendado) o namespace top-level en cada proyecto con sync — **decisión pendiente**.

---

## 6. Brechas por producto

| Producto | Brecha principal | Esfuerzo adapter |
|---|---|---|
| **POS** | `orgId`/`paidUntil`/dual license docs | 🔴 Alto |
| **Gastro** | `tenantId`/OTA coupling/webhook staging | 🔴 Alto |
| **HOME** | Sin billing — greenfield | 🟢 Bajo |
| **Aliados** | Sin billing — greenfield | 🟢 Bajo |
| **Portal** | Ninguno — no billing | ✅ N/A |

---

## 7. Orden recomendado implementación (post-aprobación)

1. **Sandbox** `0e3-billing` repo + Firestore schema
2. **Gastro staging** adapter (read-only shadow)
3. **Gastro staging** dual-write
4. **HOME** greenfield entitlement
5. **POS** shadow read prod
6. **POS** dual-write (ventana)
7. **Aliados** greenfield

---

## Referencias

- Spec: [`0e3-billing-core-spec.md`](0e3-billing-core-spec.md)
- Auditoría: [`0e3-billing-current-audit.md`](0e3-billing-current-audit.md)
- Rollout: [`0e3-billing-rollout-plan.md`](0e3-billing-rollout-plan.md)
