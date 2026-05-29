# 0E3 Billing Core — Registro de riesgos

**Versión:** 1.0  
**Fecha:** 2026-05-27  
**Estado:** Vigente — revisión post-implementación Fase 1

Escala: **Probabilidad** (Baja/Media/Alta) × **Impacto** (Bajo/Medio/Alto/Crítico) → **Prioridad** (P1–P4)

---

## Resumen por categoría

| Categoría | P1 | P2 | P3 | P4 |
|---|---|---|---|---|
| Técnicos | 2 | 4 | 3 | 2 |
| Comerciales | 1 | 2 | 2 | 1 |
| MercadoPago | 2 | 3 | 2 | 0 |
| Webhooks | 2 | 2 | 1 | 0 |
| Licencias / tenants | 2 | 3 | 2 | 0 |
| Sincronización | 1 | 3 | 2 | 0 |
| Rollback | 1 | 2 | 1 | 0 |

---

## Riesgos técnicos

| ID | Riesgo | P | I | Pri | Mitigación | Owner |
|---|---|---|---|---|---|---|
| T-01 | Dual-write desincroniza `paidUntil` vs `activeUntil` | M | Crít | **P1** | Legacy primary; reconciliación nightly; shadow 2 sem | Billing Core |
| T-02 | Transacción Firestore parcial en cutover | B | Crít | **P1** | Idempotencia webhook; retry con mismo paymentId | Billing Core |
| T-03 | `checkLicense` consulta Core caído → bloqueo masivo | M | Alto | **P2** | Fallback legacy 24h post-cutover; cache entitlement | POS |
| T-04 | ISO string vs Timestamp drift timezone | M | Med | **P2** | Comparación UTC; tolerancia 1 min shadow | Contracts |
| T-05 | Adapter onboarding_v2 mal mapeado | M | Alto | **P2** | Tests fixtures reales; shadow pagos kit | Adapter |
| T-06 | Module presets no aplicados post-migración | B | Med | **P3** | Core emite evento; POS listener existente | POS |
| T-07 | Secrets MP expuestos en logs webhook | B | Crít | **P1** | Sanitizar payload; no log body completo prod | DevOps |
| T-08 | Proyecto Firebase billing mal configurado rules | M | Alto | **P2** | Rules review; solo sandbox inicial | Security |
| T-09 | Performance scheduled shadow diff | M | Bajo | **P4** | Sample 10% tenants; paginación | Billing Core |
| T-10 | Deuda Node.js version mismatch | B | Med | **P3** | Gen2 TS; alinear con plan Node 22 | Platform |

---

## Riesgos comerciales

| ID | Riesgo | P | I | Pri | Mitigación | Owner |
|---|---|---|---|---|---|---|
| C-01 | Cliente paga y no ve extensión licencia | B | Crít | **P1** | Legacy sigue primary hasta Fase 4; gracia 24h | Producto |
| C-02 | Cambio precios durante migración | M | Alto | **P2** | Freeze admin precios ventana cutover | Ops |
| C-03 | Kit onboarding 2×$250k mal cobrado en Core | B | Alto | **P2** | Paridad tests montos; amountMatchesMercadoPago | Billing |
| C-04 | Comunicación insuficiente pre-cutover | M | Med | **P3** | Email 72h + banner in-app | Producto |
| C-05 | Percepción "doble cobro" preapproval + preference | B | Med | **P3** | UI sin cambios Fase 1-3 | UX |
| C-06 | Demo/trial tenants migrados incorrectamente | M | Bajo | **P4** | Excluir `billingModel: demo_*` del bulk sync | Adapter |

---

## Riesgos MercadoPago

| ID | Riesgo | P | I | Pri | Mitigación | Owner |
|---|---|---|---|---|---|---|
| MP-01 | Cambio webhook URL prod rompe cobros | M | Crít | **P1** | No cambiar hasta Fase 4; proxy temporal opcional | DevOps |
| MP-02 | Token prod revocado durante deploy | B | Crít | **P1** | Secret Manager versioning; no redeploy billing junto otros | DevOps |
| MP-03 | IPN duplicados / out-of-order | A | Med | **P2** | Idempotencia `billingWebhooks`; GET confirm payment | Billing Core |
| MP-04 | Monto recibido ≠ plan (fraude/error) | B | Alto | **P2** | Validación amountMatches; reject + alert | Billing Core |
| MP-05 | Preapproval cancelado sin notificar | M | Med | **P3** | Webhook subscription events fase 2 | Billing Core |
| MP-06 | Sandbox vs prod credential mix | M | Alto | **P2** | Proyectos Firebase separados; CI env guards | DevOps |
| MP-07 | Rate limit API MP en bulk reconcile | B | Med | **P3** | Backoff; batch nocturno | Billing Core |

---

## Riesgos webhooks

| ID | Riesgo | P | I | Pri | Mitigación | Owner |
|---|---|---|---|---|---|---|
| W-01 | Webhook timeout MP → retry storm | M | Alto | **P2** | 200 OK inmediato; process async setImmediate (patrón POS) | Billing Core |
| W-02 | Payload GET vs POST inconsistencia | M | Med | **P2** | Handler unificado (patrón POS existente) | Billing Core |
| W-03 | Webhook apunta a URL stale post-deploy | B | Crít | **P1** | `MERCADOPAGO_WEBHOOK_URL` explícito; verify script | DevOps |
| W-04 | Shadow tap aumenta latencia webhook | B | Med | **P3** | Async fire-and-forget; solo staging | POS |
| W-05 | Pérdida webhook en cutover gap | M | Alto | **P2** | Reconcile GET payments MP últimas 48h post-cutover | Billing Core |

---

## Riesgos licencias y tenants

| ID | Riesgo | P | I | Pri | Mitigación | Owner |
|---|---|---|---|---|---|---|
| L-01 | Tenant sin orgId en external_reference | B | Alto | **P2** | Reject + manual reconcile; alert | Webhook |
| L-02 | Gracia 24h no replicada en Core | M | Alto | **P2** | `graceDays: 1` en plan POS; computeEntitlement | Contracts |
| L-03 | Super admin bypass roto | B | Crít | **P1** | Mantener bypass en POS middleware independiente Core | POS |
| L-04 | Bulk migrate 1000+ tenants timeout | M | Med | **P3** | Batch 50; checkpoint | Migration |
| L-05 | `blocked: true` admin override perdido | B | Alto | **P2** | Migrar flag; admin API Core | Billing Core |
| L-06 | Multi-tenant user wrong org entitlement | M | Alto | **P2** | Entitlement keyed tenantId+productId; JWT companyId | Auth |
| L-07 | Sesiones concurrentes desalineadas post-cutover | B | Med | **P3** | subscriptionAccess sigue en POS; features from plan | POS |

---

## Riesgos sincronización

| ID | Riesgo | P | I | Pri | Mitigación | Owner |
|---|---|---|---|---|---|---|
| S-01 | Clock skew extensión 30 días | B | Med | **P3** | Anclar `date_approved` MP (patrón POS) | Billing Core |
| S-02 | Pago aprobado legacy, Core falla dual-write | M | Alto | **P2** | Reconciliación; legacy authoritative | Adapter |
| S-03 | Plan change mid-cycle no reflejado | M | Med | **P3** | metadata chosenPlan; event PLAN_CHANGED | Billing Core |
| S-04 | Firestore index missing query entitlements | M | Alto | **P2** | Deploy indexes pre-Fase 2 | Firebase |
| S-05 | Shadow mismatch false positive timezone | A | Bajo | **P4** | Tolerancia 1 min; UTC normalize | Shadow |

---

## Riesgos rollback

| ID | Riesgo | P | I | Pri | Mitigación | Owner |
|---|---|---|---|---|---|---|
| R-01 | Rollback Fase 4 imposible tras 4h | M | Crít | **P1** | Runbook dual-direction sync; decisión < 4h | Ops |
| R-02 | Datos Core no reversibles a legacy | M | Alto | **P2** | Forward sync script Core→legacy preparado | Billing Core |
| R-03 | Feature flags no desactivables rápido | B | Alto | **P2** | Remote config / env en Cloud Run revision | DevOps |
| R-04 | Equipo no entrenado en rollback | M | Med | **P3** | Drill trimestral sandbox | Ops |
| R-05 | Comunicación rollback a clientes | B | Med | **P3** | Template email pre-aprobado | Producto |

---

## Matriz de heat (priorizada)

```
Impacto →
         Bajo    Medio    Alto    Crítico
Prob A    T-09    MP-03    MP-03   —
Prob M    S-05    T-04     T-03    T-01
Prob B    C-06    T-06     C-03    C-01, MP-01, W-03, L-03, R-01
```

---

## Plan de respuesta P1

| ID | Trigger | Respuesta inmediata | Escalación |
|---|---|---|---|
| C-01 | Cliente sin extensión post-pago | Verificar `billingMercadoPago/pay_*`; extensión manual admin | < 1h |
| MP-01 | Webhook 404 post-cambio | Revertir URL MP a legacy | < 15 min |
| T-01 | Mismatch rate > 5% | Pausar dual-write; investigar | < 2h |
| W-03 | MP panel URL incorrecta | Fix env + verify script | < 30 min |
| L-03 | Super admin bloqueado | Hotfix bypass middleware | < 1h |
| R-01 | Cutover fallido | Ejecutar runbook rollback Fase 4 | < 4h |

---

## Revisión programada

| Evento | Acción |
|---|---|
| Post Fase 1 sandbox | Actualizar probabilidades T-* |
| Post shadow 2 sem | Cerrar riesgos S-* verificados |
| Pre cutover | Sign-off P1 mitigaciones |
| Post cutover +30d | Retirar riesgos legacy resueltos |

---

## Referencias

- Shadow: [`0e3-shadow-mode-plan.md`](0e3-shadow-mode-plan.md)
- Migración: [`0e3-pos-migration-plan.md`](0e3-pos-migration-plan.md)
- Gap analysis: [`0e3-billing-gap-analysis.md`](0e3-billing-gap-analysis.md)
