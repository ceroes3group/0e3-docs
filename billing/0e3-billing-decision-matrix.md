# 0E3 Billing Core — Matriz de decisiones

**Versión:** 1.0  
**Fecha:** 2026-05-27  
**Estado:** Aprobación Fase B0.5 — **sin implementación**

Tablas de decisión para implementación de Billing Core. Complementa [`0e3-billing-business-rules.md`](0e3-billing-business-rules.md).

**Convenciones:**

- ✅ Permitido / aplicar acción
- ❌ Denegado / bloquear
- ⚠️ Condicional / degradado
- — No aplica

---

## 1. Estado de suscripción → decisión global

| status | allowed | mode | Checkout | Sync/API write | Notificar owner |
|---|:---:|:---:|:---:|:---:|:---:|
| `trial` | ✅ | full | ✅ | ✅ | ⚠️ ≤3d fin |
| `pending` | ⚠️ | read_only | ✅ | ❌ | ✅ |
| `active` | ✅ | full | ✅ | ✅ | — |
| `paused` | ⚠️ | read_only | ✅ | ❌ | ✅ |
| `past_due` | ✅* | grace | ✅ | ⚠️** | ✅ |
| `canceled` | ✅*** | full | ✅ reactivar | ✅*** | ⚠️ fin período |
| `expired` | ❌ | blocked | ✅ | ❌ | ✅ |
| `blocked` | ❌ | blocked | ⚠️**** | ❌ | ✅ |

\* Dentro `graceUntil`.  
\** Por producto — POS bloquea ventas en gracia.  
\*** Si `now < activeUntil`.  
\**** Pago queda en cola `pending_review`.

---

## 2. Evaluación temporal → status efectivo

| Condición (now) | status almacenado | status efectivo | allowed |
|---|---|---|:---:|
| `trial` ∧ `now < trialEndsAt` | trial | trial | ✅ |
| `trial` ∧ `now ≥ trialEndsAt` | trial | **expired** | ❌ |
| `active` ∧ `now < activeUntil` | active | active | ✅ |
| `active` ∧ `now ≥ activeUntil` ∧ `now < graceUntil` | active → past_due | past_due | ✅* |
| `past_due` ∧ `now < graceUntil` | past_due | past_due | ✅* |
| `past_due` ∧ `now ≥ graceUntil` | past_due → **expired** | expired | ❌ |
| `canceled` ∧ `now < activeUntil` | canceled | canceled (activo) | ✅ |
| `canceled` ∧ `now ≥ activeUntil` | canceled → **expired** | expired | ❌ |
| `blocked = true` | any | blocked | ❌ |

\* Ver matriz producto para writes.

---

## 3. Evento webhook MP → acción Core

| Evento MP | payment.status | Monto válido | Tenant resuelto | Acción | Evento billing |
|---|---|:---:|:---:|---|---|
| IPN payment | approved | ✅ | ✅ | Extender `activeUntil`; status→active | PAYMENT_APPROVED |
| IPN payment | approved | ❌ | ✅ | Ignorar; log warn | PAYMENT_REJECTED |
| IPN payment | approved | ✅ | ❌ | Ignorar; alerta admin | — |
| IPN payment | rejected | — | ✅ | status→past_due si active | PAYMENT_REJECTED |
| IPN payment | pending | — | ✅ | status→pending | — |
| IPN payment | approved | ✅ | ✅ (dup) | No-op idempotente | duplicate |
| IPN preapproval | authorized | — | ✅ | Crear subscription active | SUBSCRIPTION_CREATED |
| IPN preapproval | cancelled | — | ✅ | cancel_pending | SUBSCRIPTION_CANCELED |

---

## 4. Acción usuario → transición plan

| Acción | Precondición | Efecto inmediato | Efecto diferido | Cobro |
|---|---|---|---|---|
| **Upgrade** | active/trial; pago OK | planId nuevo; modules↑ | — | Monto plan nuevo |
| **Downgrade** | active; límites OK | — | planId al fin período | — |
| **Cancel** | active | status→canceled | expired al fin período | — |
| **Reactivate** | expired/blocked | active + extend | — | Checkout |
| **Trial→Paid** | trial; pago OK | active | — | Primer período |
| **Admin manualActivate** | any | active; extend N días | — | — |
| **Admin suspend** | any | blocked=true | — | — |

---

## 5. Rol × acción billing

| Acción | owner | admin | cashier | operator | viewer | super_admin |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Ver entitlement | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| Checkout MP | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| Cancel sub | ✅ | ⚠️ | ❌ | ❌ | ❌ | ✅ |
| Upgrade | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| Downgrade request | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| Export data | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| Bypass license gate | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## 6. Producto × status → operaciones críticas

### POS (`pos`)

| status / mode | GET datos | POST ventas | Admin config | Invitar usuario |
|---|:---:|:---:|:---:|:---:|
| trial / full | ✅ | ✅ | ✅ | ✅* |
| active / full | ✅ | ✅ | ✅ | ✅* |
| past_due / grace | ✅ | ❌ | ✅ | ❌ |
| expired / blocked | ⚠️ | ❌ | ⚠️ billing | ❌ |
| onboarding kit | ✅ | ✅ | ✅ | ✅ |

\* Si bajo límite `maxUsers`.

### Gastro (`gastro`)

| status / mode | Tomar pedido | Cocina KDS | Sync menu | OTA update |
|---|:---:|:---:|:---:|:---:|
| trial / full | ✅ | ✅ | ✅ | ✅ |
| active / full | ✅ | ✅ | ✅ | ✅ |
| past_due / grace | ❌ | ❌ | ⚠️ read | ✅ |
| expired / blocked | ❌ | ❌ | ❌ | ✅ |
| cancel_pending | ✅ | ✅ | ✅ | ✅ |

### HOME (`home`)

| status / mode | CRUD tx | Sync cloud | Presupuestos | Invitar miembro |
|---|:---:|:---:|:---:|:---:|
| free / active | ⚠️ límite | ❌ | ❌ | ❌ |
| plus / active | ✅ | ✅ | ✅ | ❌ |
| family / active | ✅ | ✅ | ✅ | ✅* |
| expired | ❌ | ❌ | ⚠️ read | ❌ |

### Aliados (`aliados`)

| status / mode | Panel | IA scoring | Wizard público | WhatsApp |
|---|:---:|:---:|:---:|:---:|
| trial / active | ✅ | ✅ | ✅ | ✅ |
| expired | ❌ | ❌ | ✅ | ⚠️ |
| blocked | ❌ | ❌ | ✅ | ❌ |

---

## 7. Gracia — matriz detallada

| Producto | Trigger gracia | Duración | Writes permitidos | Fin gracia |
|---|---|---:|---|---|
| POS | post-activeUntil | 24h | GET sí; ventas ❌ | → expired |
| POS | unpaid (sin paidUntil) | 24h anchor | ventas ❌ | → expired |
| Gastro | past_due | 3d default | ❌ operaciones | → expired |
| HOME | past_due | 7d default | read_only | → expired |
| Aliados | past_due | 7d default | panel read | → expired |

| Admin extiende gracia | Máx extensión | Requiere motivo |
|---|:-:|---|
| +3 días | 2× por trimestre | ✅ audit log |
| +7 días | 1× por trimestre | ✅ ticket soporte |

---

## 8. Offline × cache

| Cache state | TTL restante | Último status | Acción offline | Al reconectar |
|---|:---:|---|---|---|
| fresh | >0 | active | ✅ operar | refresh |
| fresh | >0 | expired | ❌ | force blocked |
| stale | 0 | active | ⚠️ cola only | sync + validate |
| stale | 0 | any | ❌ | blocked |
| missing | — | — | ❌ | fetch required |

| Acción | Offline permitido |
|---|:---:|
| POS venta encolada | ⚠️* |
| Gastro pedido local | ⚠️* |
| HOME alta tx | ⚠️* |
| Checkout MP | ❌ |
| Cambio plan | ❌ |

\* Sync server puede rechazar si expired.

---

## 9. Multi-producto — decisión independiente

| POS status | Gastro status | Usuario POS | Usuario Gastro |
|---|:---:|---|---|
| active | active | ✅ POS | ✅ Gastro |
| active | expired | ✅ POS | ❌ Gastro |
| expired | active | ❌ POS | ✅ Gastro |
| trial | — (no contrato) | ✅ POS | N/A Gastro |

**Regla:** cada app consulta **solo** `{tenantId}_{suProductId}`.

---

## 10. Casos límite — árbol de decisión

### 10.1 Webhook perdido

```
Pago approved en MP?
├─ NO → Fin
└─ SÍ → billingWebhooks tiene paymentId?
    ├─ SÍ → Idempotente / ya aplicado
    └─ NO → reconcilePayment callable
        ├─ OK → Extender + evento
        └─ FAIL → Ticket soporte + manualActivate admin
```

### 10.2 Pago duplicado

```
Mismo paymentId?
├─ SÍ → duplicate (no-op)
└─ NO → Mismo tenant + mismo día + mismo monto?
    ├─ SÍ → Extender 2× periodDays (válido)
    └─ NO → Procesar normal
```

### 10.3 Tenant suspendido + pago

```
blocked = true?
├─ NO → Procesar pago normal
└─ SÍ → Registrar pago en billingPayments
    └─ status entitlement → pending_review
        └─ Admin reactivate → aplicar extensión
```

### 10.4 Rollback cutover

```
Tiempo post-cutover < 4h?
├─ SÍ → Revertir webhook URL legacy
│       └─ Forward sync Core→legacy pagos nuevos
└─ NO → No revertir URL
        └─ Reconciliación manual dual-direction
```

---

## 11. Onboarding POS (kit) — estados

| onboardingPaid | Fase | Próximo cobro | Plan efectivo módulos | status |
|---:|---|---|---|---|
| 0 | Kit 1/2 | $250k kit | premium (full) | active |
| 1 | Kit 2/2 | $250k kit | premium (full) | active |
| 2 | Recurrente | planPrices[chosenPlan] | chosenPlan | active |
| ≥2 + preapproval | Auto-debit | MP recurrente | chosenPlan | active |

---

## 12. Cross-sell — cuándo mostrar

| Condición tenant | Mostrar | CTA |
|---|---|---|
| pos active ≥ 30d, sin gastro | Gastro trial | "Probá 0E3 Gastro 14 días" |
| gastro active, sin pos | POS demo | "Conocé NexoPOS" |
| cualquier expired | Reactivar mismo | "Regularizá tu plan" |
| pos+gastro active | Aliados trial | "Programa aliados" |
| trial activo producto B | — | No interrumpir onboarding A |

---

## 13. Feature flag × comportamiento

| Flag | Legacy only | Shadow | Dual-write | Cutover |
|---|:---:|:---:|:---:|:---:|
| `billingCoreEnabled=false` | ✅ | — | — | — |
| `billingCoreReadOnly=true` | ✅ | ✅ compare | ✅ log | — |
| `BILLING_DUAL_WRITE=true` | write | write | write both | — |
| `BILLING_CORE_PRIMARY=true` | — | — | — | ✅ Core wins |

---

## 14. Resolución conflictos cache vs server

| Cache | Server | Decisión UI | Decisión API |
|---|---|---|---|
| active | expired | Server (blocked) | 402/403 |
| expired | active | Server (allow) | OK |
| trial | active | Server | OK |
| active | past_due grace | Server (banner) | ⚠️ product rules |
| stale/missing | any | Fetch server | Server |

---

## 15. Matriz completa status × mode × allowed

| # | status | mode | blocked flag | now vs dates | **allowed** |
|---|---|---|---|---|---|
| 1 | trial | full | false | now < trialEnds | ✅ |
| 2 | trial | blocked | true | any | ❌ |
| 3 | pending | read_only | false | any | ⚠️ |
| 4 | active | full | false | now < activeUntil | ✅ |
| 5 | active | grace | false | activeUntil ≤ now < graceUntil | ✅* |
| 6 | past_due | grace | false | now < graceUntil | ✅* |
| 7 | past_due | blocked | false | now ≥ graceUntil | ❌ |
| 8 | paused | read_only | false | any | ⚠️ |
| 9 | canceled | full | false | now < activeUntil | ✅ |
| 10 | canceled | blocked | false | now ≥ activeUntil | ❌ |
| 11 | expired | blocked | false | any | ❌ |
| 12 | blocked | blocked | true | any | ❌ |
| 13 | active | full | false | onboarding kit | ✅ |
| 14 | demo_48h | full | false | now < demoEnd | ✅ |
| 15 | demo_48h | blocked | false | now ≥ demoEnd | ❌ |

\* Aplicar restricciones writes por producto (matriz §6).

---

## Referencias

- Reglas completas: [`0e3-billing-business-rules.md`](0e3-billing-business-rules.md)
- Contratos: [`0e3-billing-contracts.md`](0e3-billing-contracts.md)
- Shadow: [`0e3-shadow-mode-plan.md`](0e3-shadow-mode-plan.md)
- Riesgos: [`0e3-billing-risk-register.md`](0e3-billing-risk-register.md)
