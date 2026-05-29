# Informe — Consolidación final ecosistema 0E3

**Fecha:** 2026-05-27  
**Alcance:** documentación, estándares, alineación — **sin lógica de negocio**

---

## 1. Qué quedó correcto ✅

| Área | Estado |
|---|---|
| **Repos GitHub producto** | `0e3-home`, `0e3-aliados`, `0e3-gastro`, `0e3-landing`, `0e3-docs` publicados |
| **Hub documentación** | `0e3-docs` con arquitectura, dominios, deploy, seguridad, roadmap, billing |
| **Portal productos** | Catálogo `/apps/` en landing + spec en `portal-products-spec.md` |
| **Aliados arquitectura** | `docs/architecture.md` — scoring, wizard, OTP, CV, IA, admin |
| **Gastro ZIPs** | Fuera del índice Git; en disco; `*.zip` en gitignore |
| **Secretos en push** | Sin `.env`/tokens en repos publicados (auditado) |
| **Dominios live** | `0e3.com.ar` + redirect `0es3.com.ar` |
| **Billing design** | Specs en `docs/billing/` — sin implementación |
| **Estándares Git/CI** | Documentados en `support-core/` |
| **Node 22 plan** | Documentado, no ejecutado |

---

## 2. Riesgos existentes ⚠️

| Riesgo | Severidad | Detalle |
|---|---|---|
| **Nombre repo `0e3-home`** | 🔴 Alta | GitHub `0e3-home` = app Flutter finanzas, no portal web |
| **Apex dominio dual** | 🟡 Media | Hoy `0e3.com.ar`; objetivo `0es3.com.ar` — requiere migración DNS |
| **Gastro Git divergente** | 🟡 Media | Local `26a2b7d` ≠ remoto `6279cd8`; workflow solo local |
| **Gastro OTA/billing site** | 🔴 Alta | Un solo site staging — no tocar deploy |
| **POS fuera org** | 🟡 Media | `danielcadiz15/nexopos-dc` — migración pendiente |
| **Aliados WIP sin push** | 🟡 Media | Features avanzadas solo locales |
| **CI workflows incompletos** | 🟡 Media | Gastro workflow bloqueado por scope OAuth |
| **Node 20/22 mix** | 🟢 Baja | Aliados/landing en 20; Functions gastro/POS en 22 |

---

## 3. Qué falta para producción completa

| Bloque | Pendiente |
|---|---|
| **Portal** | Consolidar `0e3-home` como portal Next.js en `0es3.com.ar` |
| **Dominios producto** | DNS cutover subdominios `0es3.com.ar` |
| **Ramas** | Crear `develop`, migrar desde `chore/oe3-architecture` |
| **CI/CD** | Adoptar workflows en cada repo GitHub |
| **Gastro** | Alinear Git + subir workflow (`gh auth refresh -s workflow`) |
| **Aliados** | Push WIP estable, DNS prod |
| **POS** | Migrar repo a `ceroes3group/nexopos-dc` |
| **Billing Core** | Implementación post-aprobación |
| **docs.0es3.com.ar** | Hosting estático docs |

---

## 4. Prioridades pendientes

### 🔴 Alta

| Tarea | Repo / área |
|---|---|
| Resolver naming `0e3-home` vs portal vs app Flutter | Org GitHub |
| Decidir cutover apex `0es3.com.ar` | DNS + portal |
| No tocar Gastro OTA/billing staging | Ops |
| Migración POS a org (planificado) | nexopos-dc |
| Push Aliados WIP con review seguridad | aliados |

### 🟡 Media

| Tarea | Repo / área |
|---|---|
| Alinear Gastro local/remoto | gastro |
| `gh auth refresh -s workflow` + push CI | gastro |
| Crear ramas `develop` en todos los repos | todos |
| Adoptar `web-ci.yml` / `flutter-ci.yml` | landing, aliados, gastro |
| DNS `aliados.0es3.com.ar` | aliados |
| Ejecutar `security-audit.ps1` en CI | docs template |

### 🟢 Baja

| Tarea | Repo / área |
|---|---|
| Migración Node 22 landing/aliados | ver `node-migration-plan.md` |
| `docs.0es3.com.ar` hosting | docs |
| `apps.0es3.com.ar` launcher | portal Fase 5 |
| Marketplace / red comercial | Fase 6 |

---

## Documentos generados en esta consolidación

| Documento | Ubicación |
|---|---|
| `arquitectura-general.md` | `0e3-docs` |
| `dominios.md` | `0e3-docs` |
| `deploy.md` | `0e3-docs` |
| `seguridad.md` | `0e3-docs` |
| `roadmap.md` | `0e3-docs` |
| `git-branch-strategy.md` | `0e3-docs/support-core/` |
| `ci-cd-standard.md` | `0e3-docs/support-core/` |
| `portal-products-spec.md` | `0e3-docs/support-core/` |
| `node-migration-plan.md` | `0e3-docs/support-core/` |
| `security-audit.ps1` | `0e3-docs/scripts/` |
| `architecture.md` | `0e3-aliados/docs/` |
| `GIT-REMOTE-ALIGNMENT.md` | `0e3-gastro/docs/` |

---

## Decisión estratégica requerida (humano)

**Portal corporativo en `0es3.com.ar`:**

- **Opción A:** Migrar contenido `0e3-landing` → repo `0e3-home` (renombrar/reemplazar Flutter app a otro repo)
- **Opción B:** Renombrar repos: `0e3-landing` → portal oficial; Flutter app → `0e3-home-app`
- **Opción C:** Mantener landing como portal hasta Fase 5; solo invertir DNS

Recomendación doc: **Opción B** — mínima disrupción, nombres claros.

---

⏸ Sin push automático — commits locales pendientes de aprobación.
