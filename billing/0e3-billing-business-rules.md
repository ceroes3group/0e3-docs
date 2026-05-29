# 0E3 Billing Core — Reglas de negocio

**Versión:** 1.0  
**Fecha:** 2026-05-27  
**Estado:** Aprobación Fase B0.5 — **sin implementación**

Documento normativo para Billing Core. Prevalece sobre implementaciones legacy cuando entren en conflicto **después del cutover**; durante migración, legacy mantiene primacía (ver [`0e3-pos-migration-plan.md`](0e3-pos-migration-plan.md)).

**Principio universal:** la falta de pago **nunca elimina datos** del cliente.

---

## 1. Productos

### 1.1 Catálogo

| productId | Nombre comercial | Entidad tenant | Billing hoy | Fase Core |
|---|---|---|---|---|
| `pos` | 0E3 POS / NexoPOS | `orgId` (empresa) | ✅ Prod MP | Fase 1–4 migración |
| `gastro` | 0E3 Gastro | `tenantId` | ✅ Staging MP | Post-POS cutover |
| `home` | 0E3 HOME | `familyId` / `userId`* | ❌ Greenfield | Post-Gastro |
| `aliados` | Aliados Comerciales | `orgId` aliado | ❌ Greenfield | Post-HOME beta |

\* HOME: definir `tenantId = familyId` como entidad billing en GA; durante beta, `tenantId = uid` del owner.

### 1.2 POS (`pos`)

| Atributo | Valor |
|---|---|
| Modelo comercial | Abono mensual SaaS + kit instalación opcional |
| Cobro | MercadoPago Checkout Pro + Preapproval |
| Vigencia por pago | **30 días** desde `date_approved` MP |
| Planes | `basic`, `intermediate`, `premium` |
| Onboarding | Modelo `onboarding_v2`: 2 cuotas fijas + plan elegido |
| Entidad operativa | Multi-sucursal, multi-usuario |
| Dominio objetivo | `pos.0es3.com.ar` |

**Reglas específicas POS:**

- Durante cuotas de instalación: acceso **full** (plan efectivo `premium` en módulos).
- Tras cuotas: aplicar preset módulos del `chosenPlan`.
- Middleware API bloquea **ventas** (no GET) en gracia/expiración.
- Demo self-serve: `demo_48h` (48h full) o `demo_shared` (3650d admin).

### 1.3 Gastro (`gastro`)

| Atributo | Valor |
|---|---|
| Modelo comercial | Abono mensual por tenant gastronómico |
| Cobro | MercadoPago preapproval + checkout contract |
| Planes | `base`, `premium` |
| Trial | `trial_14d` (14 días) |
| Demo | `demo_48h` |
| Entidad operativa | Tenant = local/restaurante; dispositivos/tablets |
| Dominio objetivo | `gastro.0es3.com.ar` |

**Reglas específicas Gastro:**

- Checkout solo roles `owner` | `admin` (`MercadoPagoBillingPolicy`).
- Bloqueo redirige a `/license-blocked` o `/billing`.
- OTA/APK **independiente** del estado billing en lectura cache (validación server-side en sync).
- `cancel_pending`: licencia activa hasta fin período pagado.

### 1.4 HOME (`home`)

| Atributo | Valor |
|---|---|
| Modelo comercial | Freemium → abono familiar (propuesto) |
| Cobro | MercadoPago (greenfield Core) |
| Planes propuestos | `free`, `plus`, `family` |
| Trial | 14 días `plus` al alta |
| Entidad | Familia/hogar (1–N miembros) |
| Dominio objetivo | `home.0es3.com.ar` |

**Reglas propuestas HOME:**

- Plan `free`: límites cuentas/transacciones/mes.
- Plan `plus`: sync cloud, presupuestos, metas.
- Plan `family`: multi-miembro, roles hogar.
- Sin kit instalación POS-style.

### 1.5 Aliados (`aliados`)

| Atributo | Valor |
|---|---|
| Modelo comercial | Suscripción panel aliado + captación (propuesto) |
| Cobro | MercadoPago (greenfield Core) |
| Planes propuestos | `starter`, `growth`, `enterprise` |
| Trial | 30 días `starter` |
| Entidad | Organización aliado comercial |
| Dominio objetivo | `aliados.0es3.com.ar` |

**Reglas propuestas Aliados:**

- Límites por plan: candidatos/mes, usuarios panel, IA supervisada.
- WhatsApp canal ≠ billing — no condicionar webhook WA a entitlement.
- Wizard público **no requiere** suscripción activa (captación).

---

## 2. Planes — usuarios, módulos, addons

### 2.1 Estructura de plan (schema lógico)

Cada `billingPlans/{productId}_{planId}` define:

```typescript
{
  limits: {
    includedUsers: number;
    includedBranches?: number;      // POS
    includedDevices?: number;       // Gastro
    includedFamilies?: number;      // HOME
    includedCandidatesPerMonth?: number; // Aliados
  },
  modules: Record<string, boolean>,  // POS/Gastro feature flags
  addons: AddonCatalog[],
  pricing: { amount, currency, billingFrequency, periodDays }
}
```

### 2.2 POS — planes y límites (legacy → Core)

| planId Core | Legacy | Usuarios incl. | Sucursales | Módulos clave |
|---|---|---:|---:|---|
| `pos_basic` | basic | 2 | 1 | POS, stock, ventas esencial |
| `pos_intermediate` | intermediate | 6 | 3 | + listas, transferencias, compras |
| `pos_premium` | premium | 15 | 8 | Full (producción, recetas, auditoría) |

**Addons POS (futuro Core):**

| addonId | Descripción | Precio ref. |
|---|---|---|
| `extra_user` | +1 usuario | $9k–12k/mes según plan base |
| `extra_branch` | +1 sucursal | $20k–25k/mes según plan base |
| `extra_storage` | Export/histórico extendido | TBD |

Legacy: `extraUsers`, `extraUserArs` en doc license — migrar a subscription addons.

### 2.3 Gastro — planes

| planId | Usuarios | Dispositivos | Módulos |
|---|---:|---:|---|
| `gastro_base` | 3 | 2 | POS mesa, cocina, productos |
| `gastro_premium` | 10 | 8 | + reportes avanzados, multi-sucursal futuro |

**Addons Gastro:**

| addonId | Descripción |
|---|---|
| `extra_device` | Tablet/kiosk adicional |
| `extra_user` | Usuario staff |

### 2.4 HOME — planes (propuesto)

| planId | Usuarios familia | Límites |
|---|---:|---|
| `home_free` | 1 | 50 tx/mes, 3 cuentas |
| `home_plus` | 1 | Ilimitado personal |
| `home_family` | 6 | Multi-miembro + presupuestos compartidos |

### 2.5 Aliados — planes (propuesto)

| planId | Usuarios panel | Candidatos/mes |
|---|---:|---:|
| `aliados_starter` | 2 | 50 |
| `aliados_growth` | 5 | 200 |
| `aliados_enterprise` | 20 | Ilimitado |

### 2.6 Kit instalación (solo POS)

| Parámetro | Valor default | Configurable |
|---|---|---|
| Cuotas | 2 | `platform/billing` → `billingPlans` metadata |
| Monto/cuota | $250.000 ARS | Admin 0E3 |
| Acceso durante kit | Full (`premium` modules) | No negociable v1 |
| Plan post-kit | `chosenPlan` del alta | Persistido en subscription metadata |

---

## 3. Trials

### 3.1 Duración por producto

| Producto | Trial ID | Duración | Auto-conversión |
|---|---|---:|---|
| POS | `demo_48h` | 48 horas | No — requiere pago |
| POS | `trial_30d`* | 30 días | Opcional futuro |
| Gastro | `trial_14d` | 14 días | A `base` si MP configurado |
| Gastro | `demo_48h` | 48 horas | No |
| HOME | `trial_14d` | 14 días | A `home_plus` |
| Aliados | `trial_30d` | 30 días | A `aliados_starter` |

\* POS no tiene trial estándar hoy excepto demo; definir en Core para nuevos altas greenfield.

### 3.2 Límites durante trial

| Regla | Comportamiento |
|---|---|
| Funcionalidad | **Full** del plan trial equivalente (Gastro: `premium`; POS demo: full) |
| Usuarios | Límite del plan trial, no addons |
| Checkout | Permitido desde día 1 (convertir anticipadamente) |
| Tarjeta | No requerida al inicio trial (MP preapproval opcional al convertir) |
| Extensión admin | Máx +7 días por evento; máx 2 extensiones |
| Re-trial | **1 por tenant/producto** cada 12 meses (anti-abuso) |

### 3.3 Fin de trial

| Condición | Estado siguiente | UX |
|---|---|---|
| Sin pago, trial vencido | `expired` | Pantalla bloqueo + CTA pagar |
| Pago iniciado, pendiente MP | `pending` | Banner + acceso read-only configurable |
| Pago aprobado antes fin | `active` | Transición inmediata |

---

## 4. Entitlements — qué habilitan y bloquean

### 4.1 Acciones por modo

| mode | POS | Gastro | HOME | Aliados |
|---|---|---|---|---|
| `full` | Todas operaciones | POS, cocina, sync | Sync, CRUD finanzas | Panel, IA, candidatos |
| `grace` | GET OK; POST ventas ❌ | Operaciones ❌ server | Sync lectura | Panel lectura |
| `read_only` | Solo consultas | Dashboard lectura | Ver datos | Ver candidatos |
| `blocked` | Login + billing | Login + billing | Login + billing | Login + billing |

### 4.2 Matriz habilitación por status

| status | allowed (default) | POS escribe ventas | Gastro toma pedidos | HOME sync | Aliados wizard público |
|---|---|:---:|:---:|:---:|:---:|
| `trial` | ✅ | ✅ | ✅ | ✅ | ✅ (sin suscripción)* |
| `active` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `pending` | ⚠️ read_only | ❌ | ❌ | ⚠️ | ✅ panel owner |
| `past_due` | ✅ grace | ❌ POS** | ❌ | ⚠️ | ⚠️ |
| `paused` | read_only | ❌ | ❌ | ❌ | ❌ |
| `canceled` | hasta fin período | ✅*** | ✅*** | ✅*** | ✅*** |
| `expired` | ❌ | ❌ | ❌ | ❌ | ❌ panel |
| `blocked` | ❌ | ❌ | ❌ | ❌ | ❌ |

\* Wizard público Aliados es captación — no gated por suscripción del aliado evaluador.  
\** POS legacy: gracia 24h post-`paidUntil` bloquea ventas — **mantener en adapter POS**.  
\*** Acceso hasta `activeUntil` aunque status `canceled`.

### 4.3 Features en `tenantEntitlements.features`

Ejemplos POS (copiados de module presets):

```json
{
  "ventas": true,
  "punto_venta": true,
  "produccion": false,
  "maxUsers": 6,
  "maxBranches": 3,
  "maxConcurrentSessions": 6
}
```

**Regla:** producto interpreta `features`; Core no conoce rutas UI.

---

## 5. Gracia

### 5.1 Tipos de gracia

| Tipo | Trigger | Duración default | Producto |
|---|---|---:|---|
| **Post-vencimiento** | `now > activeUntil` | POS: **24h**; otros: **3 días** | Todos |
| **Past due** | Cobro MP rechazado | `graceDays` del plan (3–7) | Core |
| **Unpaid anchor** | Sin `paidUntil` nunca | 24h desde primer request | Solo POS legacy |
| **Offline cache** | Sin red | 24–72h si último estado active | Mobile |

### 5.2 Comportamiento en gracia

| Aspecto | Regla |
|---|---|
| Status Core | `past_due` o sub-status `grace` |
| `graceUntil` | `activeUntil + graceDays` o 24h POS |
| Notificaciones | Banner in-app día 0, 1, fin gracia |
| Cobro | Checkout siempre disponible |
| Escalación | Fin gracia → `expired` automático (job o lazy eval) |
| Admin | Puede extender `graceUntil` +N días (audit log) |

### 5.3 POS — paridad legacy

Durante migración, adapter POS **debe** replicar:

- Gracia 24h post-`paidUntil`
- Bloqueo solo `POST/PUT/PATCH /ventas/*`
- GET permitido en gracia

---

## 6. Suspensión

### 6.1 Condiciones

| Causa | Actor | status resultante | Reversible |
|---|---|---|---|
| Fraude / abuso | Admin 0E3 | `blocked` | Manual |
| Chargeback confirmado | Sistema | `blocked` | Manual + revisión |
| Impago prolongado | Sistema (> grace + 30d) | `blocked` | Pago + admin |
| Violación ToS | Admin 0E3 | `blocked` | Manual |
| Mantenimiento tenant | Admin 0E3 | `paused` | Automático al fin |
| Cliente solicita pausa | Owner | `paused` | Owner reactiva |

### 6.2 Efectos suspensión

- `blocked = true` en entitlement
- Login permitido
- Datos intactos
- Email a owner (futuro)
- Webhooks MP siguen procesándose (pago puede reactivar)

---

## 7. Baja (cancelación)

### 7.1 Tipos

| Tipo | Comportamiento |
|---|---|
| **Cancel at period end** | Default — `canceled`, acceso hasta `activeUntil` |
| **Cancel immediate** | Solo admin 0E3 — acceso read-only 24h export |
| **Preapproval MP cancelado** | `cancel_pending` → activo hasta fin ciclo |

### 7.2 Retención de datos

| Plazo | Regla |
|---|---|
| 0–90 días post-expiración | Datos **completos** — reactivación self-serve |
| 90–365 días | Datos completos — reactivación con soporte |
| > 365 días inactivo | Evaluar archivo frío (export PDF/CSV ofrecido) |
| **Nunca** | Borrado automático por falta de pago |
| GDPR/AR | Export on-demand siempre disponible 30 días post-baja |

### 7.3 Reactivación

| Escenario | Proceso |
|---|---|
| `< 90d`, mismo plan | Checkout → `active`, `activeUntil += periodDays` |
| `> 90d` | Checkout + validación identidad |
| Plan discontinuado | Migrar a plan equivalente vigente |
| Deuda pendiente | Cobrar monto adeudado antes de activar (fase 2) |

---

## 8. Upgrade

### 8.1 Reglas generales

| Regla | Valor |
|---|---|
| Timing | **Inmediato** al confirmar pago upgrade |
| Prorrateo v1 | **No** — cobro monto plan nuevo completo; extensión 30d desde pago |
| Prorrateo v2 (futuro) | Crédito días restantes × diferencial |
| Módulos | Aplicar preset plan superior inmediato |
| Usuarios | Aumentar `maxUsers`; no eliminar usuarios existentes |
| Downgrade bloqueado si | Usuarios/sucursales > límite plan inferior |

### 8.2 Por producto

| Producto | Upgrade path |
|---|---|
| POS | basic → intermediate → premium |
| Gastro | base → premium |
| HOME | free → plus → family |
| Aliados | starter → growth → enterprise |

### 8.3 Onboarding → recurrente (POS)

No es upgrade — es transición automática tras cuota 2/2 al `chosenPlan`.

---

## 9. Downgrade

### 9.1 Reglas

| Regla | Valor |
|---|---|
| Timing | **Diferido** — efectivo al **fin del período pagado** |
| Solicitud | Owner/admin; registro en `billingEvents` |
| Validación pre-downgrade | `currentUsers <= target.includedUsers` AND branches/devices OK |
| Módulos | Deshabilitar módulos no incluidos — **no borrar datos** |
| Reembolso | No automático v1 |
| MP preapproval | Actualizar monto próximo ciclo o cancelar y recrear |

### 9.2 Conflictos

Si tenant excede límites plan inferior:

1. Bloquear downgrade hasta regularizar
2. Ofrecer addon o eliminar usuarios (acción manual owner)
3. Admin puede forzar downgrade con waiver (audit)

---

## 10. Cross-selling

### 10.1 Productos sugeridos

| Tenant tiene | Sugerir | Momento |
|---|---|---|
| `pos` active | `gastro` trial 14d | Post-pago POS, email día 30 |
| `gastro` active | `pos` demo 48h | Dashboard Gastro |
| `home` active | — | N/A v1 |
| `pos` + `gastro` | Aliados starter trial | Panel admin 0E3 |
| Cualquier producto expired | Mismo producto reactivar | Pantalla bloqueo |

### 10.2 Reglas cross-sell

- Descuento bundle: **fase 2** — no implementar v1
- Entitlements **independientes** — pago Gastro no extiende POS
- UI: sección "Otros productos 0E3" en `/billing`
- Tracking: `billingEvents` tipo `CROSS_SELL_SHOWN`, `CROSS_SELL_CONVERTED`

### 10.3 Bundle futuro (out of scope v1)

`bundle_pos_gastro` — un solo checkout, dos entitlements — diseño reservado.

---

## 11. Multi-producto

### 11.1 Modelo

Un **tenant comercial** puede mapear a múltiples `tenantEntitlements`:

```
tenantId: "acme_corp"
├── acme_corp_pos      → active, pos_premium
├── acme_corp_gastro   → trial, gastro_base
└── acme_corp_aliados  → (no contratado)
```

### 11.2 Reglas

| Regla | Detalle |
|---|---|
| Identidad | Mismo `tenantId` raíz; productId discrimina |
| POS orgId = Gastro tenantId | Adapter vincula manual o por email owner (fase 2) |
| Facturación | Una suscripción MP por producto v1 |
| Admin panel | Vista unificada todos los productos |
| Bloqueo | Por producto — POS activo no salva Gastro expirado |
| Alta | Cada producto checkout independiente |

### 11.3 HOME / Aliados

- HOME: `tenantId = familyId` — un entitlement por familia
- Aliados: `tenantId = orgId` panel — separado de POS salvo vinculación explícita

---

## 12. Roles

### 12.1 Roles transversales

| Rol Core | POS | Gastro | HOME | Aliados |
|---|---|---|---|---|
| `owner` | Owner empresa | owner | Creador familia | Owner org |
| `admin` | Admin empresa | admin | Admin familia | Admin panel |
| `cashier` | Cajero/vendedor | — | — | — |
| `operator` | Operador stock | staff/mesero | Miembro familia | Operador |
| `viewer` | Solo lectura | — | Solo lectura | Viewer |

### 12.2 Permisos billing por rol

| Acción | owner | admin | cashier | operator | viewer |
|---|:---:|:---:|:---:|:---:|:---:|
| Ver estado suscripción | ✅ | ✅ | ❌* | ❌ | ❌ |
| Iniciar checkout MP | ✅ | ✅ | ❌ | ❌ | ❌ |
| Cancelar suscripción | ✅ | ⚠️** | ❌ | ❌ | ❌ |
| Ver historial pagos | ✅ | ✅ | ❌ | ❌ | ❌ |
| Solicitar upgrade | ✅ | ✅ | ❌ | ❌ | ❌ |
| Export datos (baja) | ✅ | ✅ | ❌ | ❌ | ❌ |

\* POS: cajero ve banner vencimiento pero no modal admin.  
\** Admin puede cancelar si policy producto lo permite (Gastro: solo owner v1).

### 12.3 Super admin 0E3

Bypass entitlement check en **todas** las apps — no facturable, audit obligatorio.

---

## 13. Comportamiento offline

### 13.1 Parámetros cache

| Parámetro | POS mobile | Gastro tablet | HOME app |
|---|---|---|---|
| TTL online | 5 min | 5 min | 10 min |
| TTL offline max | 24h | 48h | 72h |
| Storage | localStorage + IndexedDB | Hive/SQLite | Hive |
| Key | `entitlement_{tenantId}_pos` | `entitlement_{tenantId}_gastro` | `entitlement_{familyId}_home` |

### 13.2 Reglas offline

| Regla | Comportamiento |
|---|---|
| Último estado `active`/`trial` | Permitir operaciones offline acotadas |
| TTL offline vencido | **Bloqueo conservador** — solo lectura cola |
| Cola ventas offline (POS) | Encolar; sync valida entitlement server-side |
| Gastro offline pedidos | Permitir si cache válido; rechazar sync si expired |
| Checkout MP | **Siempre online** |
| Refresh al reconectar | Force fetch entitlement |

### 13.3 Validación server-side

**Regla de oro:** cache nunca autoriza acciones irreversibles sin confirmación server en ≤24h.

- POS: sync ventas offline → API valida licencia
- Gastro: Functions callables → `assertEntitlement`
- Conflict cache vs server: **server gana**

---

## 14. Casos límite

### 14.1 Webhook perdido

| Paso | Acción |
|---|---|
| 1 | MP reintenta IPN (hasta 10 veces / 48h) |
| 2 | Cliente ve pago aprobado en MP pero licencia sin extender |
| 3 | UI: botón "Ya pagué — verificar" → callable `reconcilePayment(paymentId)` |
| 4 | Job nocturno: GET `/v1/payments/search` últimos 7 días, diff vs `billingWebhooks` |
| 5 | Admin: extensión manual + investigación |

**SLA manual:** < 4h respuesta soporte.

### 14.2 Pago duplicado

| Escenario | Regla |
|---|---|
| Mismo `paymentId` | Idempotencia — ignorar (`duplicate`) |
| Dos paymentIds mismo período | Extender `activeUntil` dos veces (doble período) — **válido** |
| Error doble click checkout | Una preferencia activa; segunda ignorada |
| Reembolso MP | No acortar `activeUntil` v1 — admin manual |

### 14.3 Pago rechazado

| status MP | Acción Core |
|---|---|
| `rejected` | `billingEvents` PAYMENT_REJECTED; no extender |
| `pending` | Mantener status; banner "Pago pendiente" |
| Preapproval pausado | `past_due` + gracia |

### 14.4 Tenant suspendido

- `blocked = true` — ignorar pagos automáticos hasta admin review
- Webhook registra pago pero **no activa** — cola `pending_review`
- Owner ve: "Cuenta suspendida — contactá soporte"

### 14.5 Rollback migración

Ver [`0e3-billing-risk-register.md`](0e3-billing-risk-register.md) R-01:

- < 4h post-cutover: revertir webhook URL, legacy primary
- Pagos procesados solo en Core: forward sync a legacy
- Nunca revocar acceso pagado válido

---

## Anexos

### A. Periodo de facturación POS

- **30 días** por pago (no mes calendario)
- Extensión: `max(date_approved, current paidUntil) + 30d`

### B. Moneda

- v1: **solo ARS**
- Multi-moneda: out of scope

### C. Referencias

- Contratos: [`0e3-billing-contracts.md`](0e3-billing-contracts.md)
- Matriz decisiones: [`0e3-billing-decision-matrix.md`](0e3-billing-decision-matrix.md)
- Entitlements: [`0e3-entitlements-access-control.md`](0e3-entitlements-access-control.md)
- POS legacy: `nexopos-dc-multi-tenant/docs/billing-mercadopago.md`
