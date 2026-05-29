# Plan de implementación Billing Core — Por producto

**Versión:** 0.1 (diseño)  
**Fecha:** 2026-05-27  
**Orden:** POS → Gastro → Home → Aliados

> **No implementar** hasta aprobación explícita post-auditoría. Esta fase es solo diseño.

---

## Fase 0 — Prerrequisitos transversales

| Item | Responsable | Estado |
|---|---|---|
| Repo `0e3-docs` con specs billing | Docs | ✅ |
| Proyecto Firebase sandbox Billing Core (opcional) | Infra | ⏸ |
| Credenciales MP test centralizadas | Humano | ⏸ |
| Feature flag framework | Dev | ⏸ |

---

## 1. 0E3 POS (prioridad 1)

### Archivos candidatos

| Archivo | Rol |
|---|---|
| `functions/routes/billing-mercadopago.routes.js` | Adapter webhook + checkout |
| `functions/index.js` | License middleware, admin billing |
| `functions/utils/onboardingBilling.js` | Onboarding kit — mantener |
| `client/src/services/billing.service.js` | API cliente |
| `client/src/pages/configuracion/configuracionempresa.js` | UI licencia |
| `client/src/utils/billingOnboarding.js` | Lógica UI onboarding |
| `functions/callables/tenants.js` | Demo licenses |

### Datos necesarios

- Mapping `orgId` → `tenantId` (1:1 inicialmente)
- Sync `paidUntil` ↔ `activeUntil`
- `platform/billing` → seed `billingPlans` POS

### Backend necesario

- Adapter escribe `tenantEntitlements/{orgId}_pos`
- Webhook dispatcher con flag `billingCoreEnabled`
- Callable `getEntitlement('pos')`

### Feature flags

- `billingCoreEnabled` por org
- `billingCoreWriteMode`: `legacy_only` | `dual_write` | `core_only`

### Tests

- Webhook idempotencia (regression existing)
- Entitlement gate en login
- Onboarding_v2 no regresiona

### Riesgos

| Riesgo | Mitigación |
|---|---|
| Producción activa | dual_write + shadow read 2 semanas |
| Webhook URL MP prod | registrar URL paralela staging primero |
| Dos colecciones licencia | adapter unifica lectura |

### Rollback

1. Flag → `legacy_only`
2. Webhook route vuelve a handler original
3. `tenantEntitlements` ignorado en middleware

---

## 2. 0E3 Gastro (prioridad 2)

### Archivos candidatos

| Archivo | Rol |
|---|---|
| `functions/src/index.ts` | Webhook, checkout, license assert |
| `functions/src/contract.ts` | Base plan contract flow |
| `functions/src/mp_config.ts` | MP secrets |
| `lib/features/billing/**` | UI Flutter |
| `lib/core/routing/session_redirect.dart` | Guards |
| `lib/features/tenants/domain/mercado_pago_billing_policy.dart` | Policy |
| `firebase.gastro-only.json` | **NO TOCAR** rewrites |

### Datos necesarios

- `tenants/{id}` fields → subscription mapping
- `subscriptionIntents` → migrar a `billingSubscriptions` gradualmente

### Backend necesario

- Nuevo módulo `billing-core/` en functions (TS)
- Webhook staging en ruta paralela `/billing-core/webhook`
- Mantener `mercadoPagoWebhook` legacy intacto

### Feature flags

- Remote config / Firestore `platformSettings/billingCore`
- Per-tenant override

### Tests

- Existing: `mercado_pago_billing_policy_test.dart`, `billing_summary_test.dart`
- New: entitlement adapter integration (staging)

### Riesgos

| Riesgo | Mitigación |
|---|---|
| OTA + billing same site | **solo staging** para pruebas Core |
| MP_BACK_URL | no cambiar hasta cutover DNS |
| APK tablets | no redeploy APK durante prueba |

### Rollback

- Flag off → Flutter lee `licenseEndsAt` legacy
- Desactivar ruta webhook Core

---

## 3. 0E3 Home (prioridad 3)

### Archivos candidatos

| Archivo | Rol |
|---|---|
| `lib/shared/providers/app_providers.dart` | Inject entitlement provider |
| `lib/shared/services/*` | Gate en operaciones |
| Nuevo: `lib/features/billing/**` | UI greenfield |
| `firebase.json` | Functions futuras |

### Datos necesarios

- Definir `tenantId` model (user vs family)
- `billingPlans/home_*` seed

### Backend necesario

- Functions mínimas: checkout + getEntitlement
- Firestore rules para read entitlement

### Feature flags

- Beta users whitelist
- Free beta → trial 90d antes de cobro

### Tests

- Widget tests pantalla vencida
- Integration auth + entitlement

### Riesgos

| Riesgo | Mitigación |
|---|---|
| Usuarios beta sin expectativa pago | comunicar antes de paywall |
| Sin Functions hoy | deploy Functions nuevo proyecto beta |

### Rollback

- Flag desactiva guards — acceso full beta

---

## 4. Aliados Comerciales (prioridad 4)

### Archivos candidatos

| Archivo | Rol |
|---|---|
| `web/src/App.tsx` | Route guards |
| `functions/src/index.ts` | Nuevas callables billing |
| Nuevo: `web/src/pages/BillingPage.tsx` | UI |
| `shared/src/types.ts` | Entitlement types |

### Datos necesarios

- Tenant = organización aliados (definir modelo)
- Planes panel + IA usage limits

### Backend necesario

- Functions billing separadas de WhatsApp webhook
- No mezclar secrets MP con WhatsApp

### Feature flags

- `billingRequired` por panel admin

### Tests

- Panel accesible con subscription active
- Wizard público no afectado (free tier opcional)

### Riesgos

| Riesgo | Mitigación |
|---|---|
| Confundir WhatsApp webhook con MP | namespaces distintos |
| WIP local sin commit | estabilizar repo antes push |

### Rollback

- Flag off — panel full acceso

---

## Cronograma sugerido (post-aprobación)

| Sprint | Entrega |
|---|---|
| S0 | Billing Core lib + Firestore schema en sandbox |
| S1 | Gastro staging adapter + tests |
| S2 | POS dual-write shadow |
| S3 | Home greenfield billing |
| S4 | Aliados billing |
| S5 | POS cutover prod (ventana planificada) |

---

## Aprobaciones humanas requeridas

| Decisión | Quién |
|---|---|
| Montos planes ARS por producto | Producto / Comercial |
| Credenciales MP prod central | Finanzas / Admin |
| Cutover POS prod | CTO + ventana mantenimiento |
| Cutover Gastro staging webhook | Dev Gastro |
| Paywall HOME beta users | Producto HOME |
| Push repos GitHub gastro (ZIP cleanup) | Dev |

---

## Referencias

- Auditoría: [`0e3-billing-current-audit.md`](0e3-billing-current-audit.md)
- Core: [`0e3-billing-core-spec.md`](0e3-billing-core-spec.md)
- MP: [`mercadopago-integration-plan.md`](mercadopago-integration-plan.md)
