# Reporte — Fase Billing Design + GitHub Docs

**Fecha:** 2026-05-27  
**Implementación código billing:** ❌ No (solo documentación)  
**MercadoPago / Functions / Firestore prod:** ❌ No tocados

---

## FASE A — GitHub / Docs

### A.1 Push `0e3-docs`

| Item | Resultado |
|---|---|
| Remote | `https://github.com/ceroes3group/0e3-docs.git` |
| Merge | Unrelated histories con repo existente (README + .gitignore resueltos) |
| Push | Ver hash post-commit abajo |

### A.2 Push landing

| Item | Resultado |
|---|---|
| Repo | `ceroes3group/0e3-landing` |
| Rango | `dadfe70..8fecdd3` |
| Commit | `docs: fix cross-references to 0e3-docs hub` |
| Estado | ✅ Sincronizado con origin |

### A.3 Remotes preparados (sin push)

| Repo local | Remote URL | Push |
|---|---|---|
| `oe3_home` | `https://github.com/ceroes3group/0e3-home.git` | ❌ Repo GitHub no existe aún |
| `aliados-comerciales` | `https://github.com/ceroes3group/0e3-aliados-comerciales.git` | ❌ No existe aún |
| `nexopos_gastro_pos` | `https://github.com/ceroes3group/0e3-gastro.git` | ❌ No existe aún |

### A.4 ZIPs trackeados en Gastro

| Archivo | Tamaño | Hash Git |
|---|---|---|
| `0e3-gastro-review-chatgpt-20260526.zip` | 0.34 MB | `0d516a6...` |
| `nexopos-gastro-review-chatgpt.zip` | **5.49 MB** | `e5332ba...` |

**Propuesta (requiere aprobación antes de ejecutar):**

```powershell
cd C:\Users\Asus\Proyectos\nexopos_gastro_pos
# Agregar a .gitignore si no está:
# *.zip
# git rm --cached "0e3-gastro-review-chatgpt-20260526.zip"
# git rm --cached "nexopos-gastro-review-chatgpt.zip"
# git commit -m "chore: remove review ZIPs from git index"
```

Los archivos **permanecen en disco**; solo salen del índice Git.

---

## FASE B–G — Documentos billing creados

| Documento | Descripción |
|---|---|
| `billing/0e3-billing-current-audit.md` | Auditoría POS, Gastro, Home, Aliados |
| `billing/0e3-billing-core-spec.md` | Modelo Firestore + estados + reglas |
| `billing/mercadopago-integration-plan.md` | MP central, webhooks, secrets |
| `billing/0e3-entitlements-access-control.md` | Acceso, gracia, bloqueo, cache |
| `billing/0e3-billing-rollout-plan.md` | Orden POS→Gastro→Home→Aliados |

---

## Hallazgos clave

1. **POS** tiene billing MP **maduro en producción** — mayor riesgo de migración.
2. **Gastro staging** tiene billing + OTA en **mismo hosting site** — crítico.
3. **HOME y Aliados** sin billing — ideal para Billing Core nativo.
4. **Landing** correctamente sin pagos.
5. Modelos **incompatibles** POS (`paidUntil`/org) vs Gastro (`licenseEndsAt`/tenant) — requiere adapters.
6. Naming secrets distinto: `MERCADOPAGO_ACCESS_TOKEN` vs `MP_ACCESS_TOKEN`.

---

## Riesgos

| Riesgo | Severidad |
|---|---|
| Tocar webhook MP POS prod | 🔴 |
| Cambiar `firebase.gastro-only.json` | 🔴 |
| Push gastro con ZIPs 5.5 MB | 🟡 |
| Unificar billing sin dual-write | 🔴 |
| OAuth MP prematuro | 🟢 — no necesario v1 |

---

## Propuesta final — 0E3 Billing Core

1. **Cuenta MP central 0E3** para abonos SaaS (preapproval + Checkout Pro).
2. **Firestore transversal** (`billingSubscriptions`, `tenantEntitlements`, …).
3. **Webhooks** con payload crudo + idempotencia.
4. **Adapters por producto** — no big-bang rewrite.
5. **Orden rollout:** sandbox Gastro → dual-write POS → Home greenfield → Aliados.
6. **Landing** permanece sin checkout.

---

## Requiere aprobación humana

- [ ] Push final `0e3-docs` con docs billing (post-merge)
- [ ] Crear repos GitHub `0e3-home`, `0e3-aliados-comerciales`, `0e3-gastro`
- [ ] Ejecutar `git rm --cached` ZIPs gastro
- [ ] Credenciales MP test central
- [ ] Montos comerciales por plan
- [ ] Inicio implementación (Fase S0 en rollout plan)
- [ ] Cualquier cambio en Functions/webhook **prod** POS o Gastro

---

## Comandos pendientes

### Crear repos GitHub (cuando apruebes)

```powershell
gh repo create ceroes3group/0e3-home --private --description "0E3 HOME app"
gh repo create ceroes3group/0e3-aliados-comerciales --private --description "0E3 Aliados Comerciales"
gh repo create ceroes3group/0e3-gastro --private --description "0E3 Gastro POS"
```

### Push productos (tras crear repos + limpiar ZIPs gastro)

```powershell
cd C:\Users\Asus\Proyectos\oe3_home
git push -u origin chore/oe3-architecture

cd C:\Users\Asus\Proyectos\0E3_WORKSPACE\aliados-comerciales
git push -u origin chore/oe3-architecture

cd C:\Users\Asus\Proyectos\nexopos_gastro_pos
git push -u origin chore/oe3-architecture
```
