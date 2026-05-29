# Reporte — Fase B0.5 (Business Rules)

**Fecha:** 2026-05-27  
**Estado:** Documentación completa — **esperando aprobación para Sandbox (Fase 1 código)**

---

## Objetivo

Definir exhaustivamente las **reglas de negocio** y la **matriz de decisiones** de Billing Core antes de escribir código del sandbox.

---

## Entregables

| Documento | Contenido |
|---|---|
| [`0e3-billing-business-rules.md`](../billing/0e3-billing-business-rules.md) | 14 secciones normativas |
| [`0e3-billing-decision-matrix.md`](../billing/0e3-billing-decision-matrix.md) | 15 tablas de decisión |

---

## Cobertura — Business Rules

| # | Tema | Estado | Highlights |
|---|---|:---:|---|
| 1 | Productos (POS, Gastro, HOME, Aliados) | ✅ | Paridad legacy POS/Gastro documentada |
| 2 | Planes (usuarios, módulos, addons) | ✅ | POS 3 tiers + kit; Gastro base/premium |
| 3 | Trials | ✅ | demo_48h, trial_14d, límites anti-abuso |
| 4 | Entitlements | ✅ | Matriz status × operaciones por producto |
| 5 | Gracia | ✅ | POS 24h legacy; Core 3–7d past_due |
| 6 | Suspensión | ✅ | blocked vs paused; fraude/chargeback |
| 7 | Baja | ✅ | Retención 90/365d; nunca borrar datos |
| 8 | Upgrade | ✅ | Inmediato v1; sin prorrateo |
| 9 | Downgrade | ✅ | Diferido fin período; validación límites |
| 10 | Cross-selling | ✅ | POS↔Gastro↔Aliados; bundle v2 diferido |
| 11 | Multi-producto | ✅ | Entitlements independientes por productId |
| 12 | Roles | ✅ | owner/admin/cashier/operator + billing perms |
| 13 | Offline | ✅ | TTL cache; server gana en sync |
| 14 | Casos límite | ✅ | Webhook perdido, dup, rollback |

---

## Cobertura — Decision Matrix

| # | Matriz | Filas/decisiones |
|---|---|---|
| 1 | Status → decisión global | 8 estados |
| 2 | Evaluación temporal | 9 condiciones |
| 3 | Webhook MP → acción | 8 eventos |
| 4 | Acción usuario → plan | 7 acciones |
| 5 | Rol × billing | 6 roles |
| 6 | Producto × operaciones | 4 productos |
| 7 | Gracia detallada | 5 productos + admin |
| 8 | Offline × cache | 4 estados cache |
| 9 | Multi-producto | 4 combinaciones |
| 10 | Casos límite (árboles) | 4 árboles |
| 11 | Onboarding POS kit | 4 fases |
| 12 | Cross-sell triggers | 5 condiciones |
| 13 | Feature flags | 4 modos migración |
| 14 | Cache vs server | 5 conflictos |
| 15 | Status × mode × allowed | 15 filas |

---

## Decisiones clave formalizadas

1. **Falta de pago nunca borra datos** — retención mínima 90 días full.
2. **POS gracia 24h** se mantiene en adapter durante migración.
3. **Upgrade inmediato** / **downgrade diferido** — v1 sin prorrateo.
4. **Entitlements por producto** — multi-producto independiente.
5. **Offline conservador** — server gana; TTL max 24–72h.
6. **Wizard Aliados público** — no gated por suscripción.
7. **Bundle cross-product** — out of scope v1.

---

## Restricciones respetadas

- ❌ Código
- ❌ Producción
- ❌ Firebase / MP / Cloudflare
- ✅ Solo documentación

---

## Próximo paso — requiere aprobación

| # | Acción | Gate |
|---|---|---|
| 1 | **Aprobar** business rules + decision matrix | Humano |
| 2 | Crear repo `ceroes3group/0e3-billing` | GitHub |
| 3 | Crear Firebase `oe3-billing-sandbox` | Infra |
| 4 | **Iniciar Fase 1 Sandbox** — `billing-contracts` package | Código |

---

## Índice billing actualizado

Ver [`README.md`](../README.md) sección billing.

---

⏸ **Esperando aprobación humana para iniciar Sandbox.**
