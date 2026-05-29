# 0e3-billing — Blueprint del repositorio conceptual

**Versión:** 1.0  
**Fecha:** 2026-05-27  
**Estado:** Diseño aprobado — **repo GitHub no creado aún**

---

## Decisión

| Item | Valor |
|---|---|
| Repo objetivo | `ceroes3group/0e3-billing` |
| Estado GitHub | ❌ No existe (verificado 2026-05-27) |
| Acción inmediata | Solo documentación en `0e3-docs` |
| Código | ⏸ Pendiente aprobación humana post Fase B |

---

## Propósito del repo

Repositorio **transversal** que centraliza:

1. Billing API (Firebase Functions / Cloud Run)
2. Webhook handler MercadoPago unificado
3. Entitlement service (`tenantEntitlements`)
4. Schemas y contratos compartidos
5. Adapters legacy (POS, Gastro, futuro HOME/Aliados)
6. Panel admin billing (React, fase 2)

**No incluye:** UI de checkout por producto (cada app conserva su modal/pantalla licencia).

---

## Estructura de directorios (futura)

```
0e3-billing/
├── README.md
├── docs/                          # Symlink o copia selectiva desde 0e3-docs/billing/
├── packages/
│   ├── billing-contracts/         # TypeScript types + JSON Schema + validadores
│   │   ├── src/
│   │   │   ├── billingPlans.ts
│   │   │   ├── billingSubscriptions.ts
│   │   │   ├── tenantEntitlements.ts
│   │   │   ├── billingWebhooks.ts
│   │   │   ├── billingEvents.ts
│   │   │   └── index.ts
│   │   └── schemas/               # JSON Schema export
│   └── billing-adapters/
│       ├── pos/                   # orgId → tenantId, paidUntil → activeUntil
│       └── gastro/                # licenseEndsAt → activeUntil (fase posterior)
├── functions/                     # Firebase Functions Gen2 (TypeScript)
│   ├── src/
│   │   ├── index.ts
│   │   ├── api/                   # HTTP routes
│   │   ├── callables/
│   │   ├── webhooks/
│   │   │   └── mercadopago.ts
│   │   ├── services/
│   │   │   ├── entitlementService.ts
│   │   │   ├── subscriptionService.ts
│   │   │   └── planCatalogService.ts
│   │   ├── adapters/
│   │   │   └── posLegacyAdapter.ts
│   │   └── shadow/
│   │       └── shadowCompare.ts   # Fase shadow-read
│   └── package.json
├── admin/                         # Panel React agentes 0E3 (fase 2)
├── firebase.json                  # Proyecto sandbox dedicado
├── firestore.rules                # Solo sandbox inicialmente
└── .github/workflows/
    └── ci.yml
```

---

## Proyecto Firebase asociado (futuro)

| Entorno | Project ID propuesto | Notas |
|---|---|---|
| Sandbox | `oe3-billing-sandbox` | Desarrollo + shadow-read |
| Staging | `oe3-billing-staging` | Dual-write POS staging |
| Producción | `oe3-billing` o compartido `nexopos-dc` | Decisión en cutover — preferir proyecto dedicado |

**Restricción actual:** no crear proyecto Firebase hasta aprobación post-Fase B.

---

## Dependencias con otros repos

| Repo | Relación |
|---|---|
| `0e3-docs` | Fuente de verdad documentación; este repo implementa specs |
| `nexopos-dc-multi-tenant` | Adapter POS + shadow-read; **no modificar prod** hasta Fase 4 |
| `0e3-gastro` | Adapter Gastro — **diferido** post-POS |
| `0e3-home`, `0e3-aliados` | Greenfield — escribir directo en Core |

---

## Primer commit (cuando se cree el repo)

Contenido mínimo sin lógica de negocio:

1. `README.md` con links a `0e3-docs/billing/`
2. `packages/billing-contracts/` con tipos vacíos / stubs
3. `firebase.json` sandbox
4. `.gitignore`, `LICENSE` (privado org)

---

## Referencias

- Spec: [`0e3-billing-core-spec.md`](0e3-billing-core-spec.md)
- Contratos: [`0e3-billing-contracts.md`](0e3-billing-contracts.md)
- Extracción POS: [`0e3-pos-billing-extraction-plan.md`](0e3-pos-billing-extraction-plan.md)
- Migración: [`0e3-pos-migration-plan.md`](0e3-pos-migration-plan.md)
