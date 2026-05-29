# 0E3 Billing Core — Contratos compartidos

**Versión:** 1.0  
**Fecha:** 2026-05-27  
**Estado:** Diseño aprobado — implementación en `0e3-billing/packages/billing-contracts`

Contratos para: `billingPlans`, `billingSubscriptions`, `tenantEntitlements`, `billingWebhooks`, `billingEvents`.

---

## Convenciones globales

| Regla | Valor |
|---|---|
| IDs string | `[a-z0-9_-]+`, max 128 chars |
| Timestamps | Firestore `Timestamp`; API expone ISO 8601 UTC |
| Moneda default | `ARS` |
| Provider default | `mercadoPago` |
| Product IDs | `pos`, `gastro`, `home`, `aliados` |
| Tenant ID | Opaco; POS: igual a `orgId` |

---

## 1. `billingPlans`

Catálogo de planes comerciales por producto.

### Document ID

`{productId}_{planId}` — ej. `pos_basic`, `pos_premium`, `gastro_base`

### Interface TypeScript

```typescript
type BillingFrequency = 'monthly' | 'yearly' | 'one_time';
type ProductId = 'pos' | 'gastro' | 'home' | 'aliados';

interface BillingPlan {
  /** Igual al document ID */
  id: string;
  productId: ProductId;
  /** Slug corto dentro del producto: basic, intermediate, premium, base, … */
  planId: string;
  name: string;
  description?: string;
  amount: number;              // >= 0, 2 decimales ARS
  currency: 'ARS';
  billingFrequency: BillingFrequency;
  /** Días de trial al alta (0 = none) */
  trialDays: number;
  /** Días post past_due antes de blocked */
  graceDays: number;
  /** Días de vigencia por pago aprobado (POS legacy: 30) */
  periodDays: number;
  /** Flags módulos / límites — opaco por producto */
  features: Record<string, boolean | number | string>;
  /** Onboarding kit — opcional */
  onboarding?: {
    installmentAmount: number;
    installmentsTotal: number;
    fullAccessDuringOnboarding: boolean;
  };
  mercadoPagoPreapprovalPlanId?: string;
  active: boolean;
  sortOrder?: number;
  createdAt: string;
  updatedAt: string;
}
```

### Validaciones

| Campo | Regla |
|---|---|
| `amount` | `>= 0`; checkout requiere `> 0` |
| `trialDays`, `graceDays`, `periodDays` | Entero `>= 0` |
| `onboarding.installmentsTotal` | 1–24 |
| `productId` + `planId` | Único compuesto |
| `features` | Objeto JSON serializable, max 64 keys |

### Seed POS (migración)

| planId legacy | Core ID | amount default |
|---|---|---|
| `basic` | `pos_basic` | 80000 |
| `intermediate` | `pos_intermediate` | 120000 |
| `premium` | `pos_premium` | 180000 |

Onboarding POS → `pos_onboarding_kit` metadata en plan o sub-doc `onboarding` en `pos_premium`.

---

## 2. `billingSubscriptions`

Suscripción activa o histórica por tenant + producto.

### Document ID

Auto-ID Firestore o `{tenantId}_{productId}` si single-subscription (v1 POS).

### Interface TypeScript

```typescript
type SubscriptionStatus =
  | 'trial'
  | 'pending'
  | 'active'
  | 'paused'
  | 'past_due'
  | 'canceled'
  | 'expired'
  | 'blocked';

interface BillingSubscription {
  id: string;
  tenantId: string;
  productId: ProductId;
  businessId?: string;
  planId: string;
  provider: 'mercadoPago';
  providerSubscriptionId?: string;   // preapproval id
  providerPayerId?: string;
  status: SubscriptionStatus;
  statusDetail?: string;
  amount: number;
  currency: 'ARS';
  billingFrequency: BillingFrequency;
  startDate: string;
  nextBillingDate?: string;
  trialEndsAt?: string;
  activeUntil: string;               // fuente vigencia efectiva
  graceUntil?: string;
  canceledAt?: string;
  lastPaymentId?: string;
  lastPaymentStatus?: 'approved' | 'rejected' | 'pending' | 'refunded';
  metadata?: {
    onboardingPaidCount?: number;
    chosenPlanId?: string;
    legacyOrgId?: string;
    billingModel?: string;
  };
  createdAt: string;
  updatedAt: string;
}
```

### Validaciones

| Regla | Detalle |
|---|---|
| Un tenant + producto | Max 1 subscription `active|trial|past_due` (v1) |
| `activeUntil` | Requerido si `status` in (`active`, `trial`, `past_due`) |
| Transiciones | Ver máquina de estados en `0e3-billing-core-spec.md` |
| `amount` | Debe coincidir con plan al crear; drift permitido en metadata |

### Índices Firestore

- `(tenantId, productId, status)`
- `(providerSubscriptionId)` unique sparse

---

## 3. `tenantEntitlements`

Vista materializada — **fuente de consulta rápida** para apps.

### Document ID

`{tenantId}_{productId}` — ej. `acme123_pos`

### Interface TypeScript

```typescript
type EntitlementMode = 'full' | 'grace' | 'read_only' | 'blocked';

interface TenantEntitlement {
  tenantId: string;
  productId: ProductId;
  subscriptionId?: string;
  planId: string;
  status: SubscriptionStatus;
  /** Decisión computada server-side */
  allowed: boolean;
  mode: EntitlementMode;
  activeUntil?: string;
  graceUntil?: string;
  trialEndsAt?: string;
  features: Record<string, boolean | number | string>;
  blocked: boolean;
  blockReason?: string;
  checkoutUrl?: string;
  /** Shadow mode — comparación legacy */
  shadow?: {
    legacyPaidUntil?: string;
    lastComparedAt?: string;
    mismatch?: boolean;
    mismatchFields?: string[];
  };
  updatedAt: string;
}
```

### Validaciones

| Regla | Detalle |
|---|---|
| `allowed` | **Solo backend escribe** — apps read-only |
| TTL cache cliente | Max 5 min; acciones críticas re-fetch |
| `features` | Copiado de plan + overrides admin |

### Función pura `computeEntitlement(sub, plan, now)`

```
allowed = true SI:
  (status == active AND now < activeUntil)
  OR (status == trial AND now < trialEndsAt)
  OR (status == past_due AND now < graceUntil)
  AND NOT blocked

mode = grace SI status == past_due OR within grace window post activeUntil
mode = blocked SI NOT allowed
```

---

## 4. `billingWebhooks`

Registro crudo + resultado procesamiento (idempotencia).

### Document ID

`{provider}_{providerEventId}` — ej. `mercadopago_pay_123456789`

POS legacy equivalente: `billingMercadoPago/pay_{paymentId}`

### Interface TypeScript

```typescript
type WebhookProcessingResult = 'ok' | 'ignored' | 'duplicate' | 'error';

interface BillingWebhook {
  id: string;
  provider: 'mercadoPago';
  providerEventId: string;
  eventType: 'payment' | 'subscription' | 'unknown';
  /** Payment ID extraído */
  resourceId?: string;
  tenantId?: string;
  productId?: ProductId;
  headers: Record<string, string>;
  payload: Record<string, unknown>;
  receivedAt: string;
  processedAt?: string;
  processingResult: WebhookProcessingResult;
  errorMessage?: string;
  /** Side effects aplicados */
  effects?: {
    subscriptionId?: string;
    activeUntil?: string;
    paymentId?: string;
  };
}
```

### Validaciones

| Regla | Detalle |
|---|---|
| Idempotencia | Si `processingResult == ok|duplicate` → no reprocesar |
| `payload` | Max 256 KB; sanitizar tokens |
| Retención | 90 días mínimo (compliance MP) |

### Flujo POS mapeado

1. MP POST/GET webhook → crear doc `pending`
2. GET `/v1/payments/{id}` → validar `approved`
3. Resolver tenant → aplicar extensión
4. Marcar `ok` + `effects`

---

## 5. `billingEvents`

Eventos de dominio internos (auditoría, shadow, integraciones).

### Document ID

Auto-ID

### Interface TypeScript

```typescript
type BillingEventType =
  | 'CHECKOUT_CREATED'
  | 'PAYMENT_APPROVED'
  | 'PAYMENT_REJECTED'
  | 'SUBSCRIPTION_CREATED'
  | 'SUBSCRIPTION_CANCELED'
  | 'ENTITLEMENT_UPDATED'
  | 'ENTITLEMENT_BLOCKED'
  | 'ADMIN_MANUAL_ACTIVATE'
  | 'SHADOW_MISMATCH'
  | 'SHADOW_MATCH'
  | 'LEGACY_SYNC';

interface BillingEvent {
  id: string;
  type: BillingEventType;
  tenantId: string;
  productId: ProductId;
  subscriptionId?: string;
  correlationId?: string;        // paymentId, webhookId
  actor?: {
    type: 'system' | 'admin' | 'webhook' | 'user';
    uid?: string;
    email?: string;
  };
  payload: Record<string, unknown>;
  createdAt: string;
}
```

### Validaciones

| Regla | Detalle |
|---|---|
| Append-only | No updates; solo create |
| `SHADOW_*` | Emitir en shadow-read/compare |
| Retención | 365 días |

---

## API surface (contratos HTTP/callable)

### `billing.getPlans`

```typescript
// Request
{ productId: ProductId }

// Response
{ plans: BillingPlan[]; mercadoPagoConfigured: boolean }
```

### `billing.getEntitlement`

```typescript
// Request
{ tenantId: string; productId: ProductId }

// Response
TenantEntitlement
```

### `billing.createCheckout`

```typescript
// Request
{
  tenantId: string;
  productId: ProductId;
  planId: string;
  returnUrls?: { success: string; failure: string; pending: string };
}

// Response
{
  initPoint: string;
  preferenceId: string;
  phase: 'onboarding' | 'recurring';
  amount: number;
}
```

---

## JSON Schema

Implementación futura en `0e3-billing/packages/billing-contracts/schemas/`:

- `billing-plan.schema.json`
- `billing-subscription.schema.json`
- `tenant-entitlement.schema.json`
- `billing-webhook.schema.json`
- `billing-event.schema.json`

Validación runtime: Ajv (Node) + codegen Dart para Flutter (fase 2).

---

## Referencias

- Spec general: [`0e3-billing-core-spec.md`](0e3-billing-core-spec.md)
- Entitlements: [`0e3-entitlements-access-control.md`](0e3-entitlements-access-control.md)
- Extracción POS: [`0e3-pos-billing-extraction-plan.md`](0e3-pos-billing-extraction-plan.md)
