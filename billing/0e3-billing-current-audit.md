# Auditoría billing actual — Ecosistema 0E3

**Fecha:** 2026-05-27  
**Alcance:** read-only — sin cambios en código, Functions, Firestore rules ni MercadoPago  
**Objetivo:** inventariar lo existente antes de diseñar **0E3 Billing Core**

---

## Resumen ejecutivo

| Producto | Billing SaaS | MercadoPago abono | Firestore licencia | Frontend checkout | Riesgo migración |
|---|---|:---:|:---:|:---:|---|
| **0E3 POS** | ✅ Maduro | ✅ Prod | ✅ `licenses`, `platform/billing` | ✅ React | 🔴 Alto — producción activa |
| **0E3 Gastro** | ✅ Staging | ✅ Staging | ✅ `tenants/*` | ✅ Flutter | 🔴 Crítico — OTA + billing site |
| **0E3 HOME** | ❌ No | ❌ | ❌ | ❌ | 🟢 Greenfield |
| **Aliados** | ❌ No | ❌ | ❌ | ❌ | 🟢 Greenfield |
| **Landing** | ❌ No | ❌ | — | — | ✅ Correcto (solo institucional) |

**Conclusión:** POS y Gastro ya implementan cobro de **licencia SaaS** con MercadoPago de forma **independiente y no unificada**. HOME y Aliados parten de cero. La landing **no debe** procesar pagos.

---

## 1. 0E3 POS (`nexopos-dc-multi-tenant`)

### Qué existe hoy

| Capa | Ubicación | Descripción |
|---|---|---|
| **Functions route** | `functions/routes/billing-mercadopago.routes.js` | Checkout Pro, preapproval, webhook |
| **Functions index** | `functions/index.js` | Monta `/billing/*`, secreto `MERCADOPAGO_ACCESS_TOKEN` |
| **Admin billing** | `GET/PUT /admin/platform/billing` | Precios por plan en Firestore |
| **Frontend service** | `client/src/services/billing.service.js` | Preferencias MP, config pública |
| **Frontend UI** | `client/src/pages/configuracion/configuracionempresa.js` | Modal licencia + botón MP |
| **Onboarding utils** | `client/src/utils/billingOnboarding.js`, `functions/utils/onboardingBilling.js` | Kit inicial 2×$250k + plan elegido |
| **License gate** | `functions/index.js` (middleware sesión) | Fases `demo_active`, `demo_expired`, bloqueo |
| **Tenants callables** | `functions/callables/tenants.js` | `billingModel`: `demo_48h`, `onboarding_v2`, `demo_shared` |
| **Docs** | `docs/billing-mercadopago.md` | Guía operativa completa |

### Firestore

| Colección / doc | Campos relevantes |
|---|---|
| `platform/billing` | `planPrices`, `monthlyPriceARS`, onboarding installments |
| `companies/{orgId}/config/license` | `plan`, `chosenPlan`, `paidUntil`, `blocked`, `billingModel`, `demo` |
| `licenses/{orgId}` | Mirror legacy de licencia |
| `billingMercadoPago/pay_{paymentId}` | Idempotencia webhook |

### MercadoPago

- **Token:** `MERCADOPAGO_ACCESS_TOKEN` (Firebase Secret)
- **Webhook:** `/api/billing/mercadopago/webhook`
- **Modos:** Checkout Pro (pago único +30 días) + Preapproval (recurrente)
- **Precios default hardcodeados:** Básica $80k, Intermedia $120k, Premium $180k ARS
- **Onboarding hardcodeado:** 2 cuotas × $250.000 ARS (`onboardingBilling.js`)

### Frontend

- `getBillingPublicConfig()` — expone precios y flag `mercadoPagoTokenPresent` (no el token)
- `createLicenseMercadoPagoPreference()` — crea preferencia vía API
- `paidUntil`, `blocked`, `plan` en estado local licencia
- Método de pago **MercadoPago** en POS ventas = referencia de cobro en mostrador (distinto de billing SaaS)

### Qué es seguro reutilizar (conceptualmente)

- Patrón webhook → confirmar pago vía GET `/v1/payments/:id`
- Idempotencia con doc por `paymentId`
- Extensión `paidUntil` anclada a `date_approved`
- Separación token en Secret Manager
- Modelo planes `basic | intermediate | premium`

### Qué NO tocar sin auditoría + ventana

- `billing-mercadopago.routes.js` en producción
- Webhook URL registrada en MP producción
- `platform/billing` en Firestore prod
- Flujo onboarding_v2 (kit + cuotas)
- Middleware de bloqueo por licencia en `functions/index.js`

### Riesgos

| Riesgo | Severidad |
|---|---|
| POS prod con clientes pagando | 🔴 |
| URLs hardcodeadas `nexopos-dc.web.app` en webhook/back_urls | 🟡 |
| Dos fuentes licencia (`companies/.../license` + `licenses/`) | 🟡 |
| Planes legacy `pro`/`enterprise` normalizados en runtime | 🟢 |

---

## 2. 0E3 Gastro (`nexopos_gastro_pos`)

### Qué existe hoy

| Capa | Ubicación | Descripción |
|---|---|---|
| **Functions** | `functions/src/index.ts` | MP webhook, checkout, admin manual |
| **Contract flow** | `functions/src/contract.ts` | Checkout base plan, provision tenant, intent webhooks |
| **MP config** | `functions/src/mp_config.ts` | Secrets `MP_ACCESS_TOKEN`, `MP_WEBHOOK_SECRET`, env plans |
| **Flutter billing** | `lib/features/billing/` | Pantallas, repository, summary |
| **Policy** | `lib/features/tenants/domain/mercado_pago_billing_policy.dart` | Reglas checkout/cancel |
| **License gate** | `assertTenantLicenseIsUsable()` en Functions | `licenseStatus`, `trialEndsAt`, `licenseEndsAt` |
| **Session redirect** | `lib/core/routing/session_redirect.dart` | Rutas bloqueadas vs `/billing` |
| **Hosting billing** | Site `e3-gastro-staging` | `/billing/` estático + Functions |
| **Docs** | `docs/FUNCTIONS_ENV_SETUP.md`, `docs/MERCADOPAGO_STAGING_SETUP.md`, `docs/mercado-pago-backend.md` |

### Firestore

| Colección / path | Campos relevantes |
|---|---|
| `tenants/{id}` | `licenseStatus`, `plan`, `trialEndsAt`, `licenseEndsAt`, `enabled`, `mercadoPagoSubscriptionId`, `mercadoPagoCustomerId`, `lastPaymentStatus` |
| `tenants/{id}/billingPayments/{id}` | Checkout pendientes |
| `tenants/{id}/billingEvents/{id}` | Eventos webhook |
| `subscriptionIntents/{id}` | Flujo contract checkout |
| `subscriptionIntentSecrets/{id}` | Secrets provisioning |
| `platformAdmins/{uid}` | Admin manual payment |

### MercadoPago (staging)

| Variable | Uso |
|---|---|
| `MP_ACCESS_TOKEN` | Secret — API calls |
| `MP_WEBHOOK_SECRET` | Firma HMAC webhook |
| `MP_BACK_URL` | Return post-checkout → `/billing/` |
| `MP_PLAN_BASE_AMOUNT`, `MP_PLAN_BASE_DAYS` | Plan base |
| `MP_PLAN_*_PREAPPROVAL_PLAN_ID` | Plan MP opcional |

- **Webhook:** `mercadoPagoWebhook` — payments + preapproval
- **Planes:** `base`, `premium` (+ trial `trial_14d`, demo `demo_48h`)
- **Estados licencia:** `trial`, `active`, `expired`, `cancel_pending`, `suspended`

### Frontend Flutter

- `/billing`, `/billing/activate-base` — pantallas cobro
- `BillingSummary` — avisos dashboard
- `createSubscriptionCheckout` callable — preapproval
- Bloqueo POS/caja si licencia vencida (Functions-side)

### Qué es seguro reutilizar (conceptualmente)

- `MercadoPagoBillingPolicy` como capa de reglas UI
- Patrón `external_reference = tenantId:plan`
- Admin manual: `manualPaymentMark`, `extendTrial`, `suspendTenant`
- Tests: `test/mercado_pago_billing_policy_test.dart`, `test/billing_summary_test.dart`

### Qué NO tocar sin auditoría

- **`mercadoPagoWebhook`** en staging/prod
- **`firebase.gastro-only.json`** y rewrites `/billing/`, `/apk/`, `/app-updates/`
- **`functions/.env.e3-gastro-staging`** (MP_BACK_URL, tokens)
- **`contract.ts`** provisioning + intent secrets
- Site **`e3-gastro-staging`** (APK+OTA+billing unificado)
- Scripts deploy Android / workflows hosting

### Riesgos

| Riesgo | Severidad |
|---|---|
| Tablets con OTA apuntando al mismo site que billing | 🔴 |
| Webhook + back_url atados a `e3-gastro-staging.web.app` | 🔴 |
| Staging bypass policy (`staging_bypass_config.ts`) | 🟡 |
| Modelo distinto a POS (tenant vs org) | 🟡 — unificación requiere mapping |

---

## 3. 0E3 HOME (`oe3_home`)

### Qué existe hoy

- **Sin integración MercadoPago** para abono SaaS
- **Sin colecciones** de licencia/suscripción en código revisado
- Modo **demo local** (`DemoDataStore`, repositorios demo) — no billing cloud
- Firebase project: `oe3-home-beta` — beta funcional sin paywall

### Hardcode / flags

- `AppConstants.demoFamilyId`, `demoUserId` — datos demo offline
- Sin `licenseStatus`, `paidUntil`, `activeUntil` en modelos Firestore productivos

### Qué es seguro reutilizar

- Infra Firebase beta existente
- Patrón auth + tenant/family scope para futuro entitlement

### Riesgos

| Riesgo | Severidad |
|---|---|
| Usuarios beta sin modelo comercial | 🟡 — definir antes de GA |
| Sin backend Functions dedicado billing | 🟢 — implementación limpia posible |

---

## 4. Aliados Comerciales (`aliados-comerciales`)

### Qué existe hoy

- **Sin billing SaaS** — panel + wizard + WhatsApp webhook
- `whatsappWebhook` en Functions — **no es billing**, es canal Meta
- Sin Firestore de suscripción/planes

### Qué NO confundir

- Webhook WhatsApp ≠ webhook MercadoPago
- `buildScoreExplanation` / scoring — dominio comercial aliados, no pagos

### Riesgos

| Riesgo | Severidad |
|---|---|
| Greenfield — diseño desde Billing Core | 🟢 |
| Functions con secrets WhatsApp/OpenAI | 🟡 — no mezclar con MP secrets |

---

## 5. Landing (`0e3.com.ar`)

- ✅ **Sin procesamiento de pagos** — correcto según arquitectura
- Solo links a productos `.web.app` / futuros subdominios
- **No agregar** checkout ni MP en landing

---

## Matriz comparativa — modelos actuales

| Aspecto | POS | Gastro |
|---|---|---|
| Entidad billing | `orgId` / company | `tenantId` |
| Vigencia | `paidUntil` (ISO) | `licenseEndsAt` (Timestamp) |
| Trial | `demo_48h`, demo express | `trial_14d`, `demo_48h` |
| Planes | basic/intermediate/premium | base/premium |
| Onboarding kit | 2×$250k ARS | No equivalente |
| Webhook idempotencia | `billingMercadoPago/pay_*` | `billingEvents/{id}` |
| Token secret name | `MERCADOPAGO_ACCESS_TOKEN` | `MP_ACCESS_TOKEN` |

---

## Recomendación pre-Billing Core

1. **No unificar código** POS + Gastro en caliente — usar **adaptadores por producto** hacia modelo común.
2. **Auditoría MP producción POS** antes de cualquier cambio de webhook.
3. **Gastro staging** — entorno de prueba para Billing Core v1 antes de POS prod.
4. **HOME y Aliados** — implementar Billing Core nativo sin deuda legacy.
5. Mantener landing **sin pagos**.

---

## Referencias

- POS: `nexopos-dc-multi-tenant/docs/billing-mercadopago.md`
- Gastro: `nexopos_gastro_pos/docs/FUNCTIONS_ENV_SETUP.md`
- Hub hosting: [`../firebase/oe3-hosting-map.md`](../firebase/oe3-hosting-map.md)
