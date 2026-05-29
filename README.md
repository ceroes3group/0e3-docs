# 0E3 Documentation Hub

Repositorio central de documentación transversal del ecosistema **0E3 · Cero Es Tres**.

**Repo:** [ceroes3group/0e3-docs](https://github.com/ceroes3group/0e3-docs)

---

## Estado actual — dominios

| Rol | Dominio | Estado |
|---|---|---|
| Raíz institucional | `https://0e3.com.ar` | ✅ Live + SSL |
| Alias redirect 301 | `https://0es3.com.ar` → `0e3.com.ar` | ✅ Configurado (Cloudflare) |
| POS / NexoPOS | `pos.0e3.com.ar` | ⏸ Pendiente cutover |
| 0E3 HOME | `home.0e3.com.ar` | ⏸ Pendiente cutover |
| Aliados Comerciales | `aliados.0e3.com.ar` | ⏸ Pendiente cutover |
| Gastro web staging | `staging.gastro.0e3.com.ar` | ⏸ Pendiente cutover |
| Gastro APK/OTA/billing staging | `staging.0e3.com.ar` | ⏸ Pendiente — **crítico** |
| Gastro prod | `gastro.0e3.com.ar` | ⏸ Sin deploy prod |
| Docs | `docs.0e3.com.ar` | ⏸ Futuro |

**Regla:** no renombrar Firebase project IDs ni site IDs (ej. site `0es3-com-ar` en landing).

---

## Mapa de proyectos Firebase

| Project ID | Producto | Hosting site(s) | URL operativa |
|---|---|---|---|
| `oe3-institutional` | Landing institucional | `0es3-com-ar` | https://0e3.com.ar |
| `oe3-aliados-comerciales` | Aliados Comerciales | default | https://oe3-aliados-comerciales.web.app |
| `oe3-home-beta` | 0E3 HOME | default | https://oe3-home-beta.web.app |
| `nexopos-dc` | NexoPOS / 0E3 POS | `nexopos-dc`, `nexopos-gastro-pos` | https://nexopos-dc.web.app |
| `nexopos-dc-staging` | POS staging | default | https://nexopos-dc-staging.web.app |
| `e3-gastro-staging` | Gastro staging | `e3-gastro-staging`, `e3-gastro-staging-web` | APK/OTA + web PWA |
| `e3-gastro` | Gastro producción | `e3-gastro`, `e3-gastro-web` | Sin deploy activo |

Detalle completo: [`firebase/oe3-hosting-map.md`](firebase/oe3-hosting-map.md)

---

## Mapa de repos GitHub

| Repo | Estado remoto | Branch principal |
|---|---|---|
| [0e3-landing](https://github.com/ceroes3group/0e3-landing) | ✅ Publicado | `main` |
| [0e3-docs](https://github.com/ceroes3group/0e3-docs) | ✅ Publicado | `main` |
| [0e3-aliados-comerciales](https://github.com/ceroes3group/0e3-aliados-comerciales) | ✅ Publicado | `chore/oe3-architecture` |
| [0e3-home](https://github.com/ceroes3group/0e3-home) | ✅ Publicado | `chore/oe3-architecture` |
| [0e3-gastro](https://github.com/ceroes3group/0e3-gastro) | ✅ Publicado | `chore/oe3-architecture` |

---

## Decisiones tomadas

1. **Portal objetivo:** `0es3.com.ar` — hub marca + productos (transición desde `0e3.com.ar` / `0e3-landing`).
2. **`0es3.com.ar`** redirect hacia apex portal (migración DNS pendiente).
3. Landing export estático Next.js → Firebase site **`0es3-com-ar`** (ID no renombrable).
4. Cada producto: **repo + deploy + Firebase** separados.
5. Estandarizar ramas: `main`, `develop`, `feature/*`, `hotfix/*`, `release/*`.
6. POS, Gastro prod, OTA, billing — **fuera de alcance** sin plan explícito.

---

## Índice principal

| Documento | Descripción |
|---|---|
| [arquitectura-general.md](arquitectura-general.md) | Visión ecosistema y separación de capas |
| [dominios.md](dominios.md) | Mapa DNS objetivo `0es3.com.ar` |
| [deploy.md](deploy.md) | Deploy por producto |
| [seguridad.md](seguridad.md) | Secretos y checklist |
| [roadmap.md](roadmap.md) | Fases 1–6 |
| [reports/FASE-N-ESTRATEGICA-REPORTE.md](reports/FASE-N-ESTRATEGICA-REPORTE.md) | Fase N — naming, ownership, gaps |
| [reports/FASE-B-BILLING-PREPARATION-REPORTE.md](reports/FASE-B-BILLING-PREPARATION-REPORTE.md) | Fase B — preparación Billing Core |
| [reports/FASE-CONSOLIDACION-FINAL.md](reports/FASE-CONSOLIDACION-FINAL.md) | Informe consolidación |

### architecture/

| Documento | Descripción |
|---|---|
| [0e3-product-ownership-map.md](architecture/0e3-product-ownership-map.md) | Repo ↔ dominio ↔ producto |
| [0e3-final-ecosystem-structure.md](architecture/0e3-final-ecosystem-structure.md) | Estructura definitiva propuesta |

### support-core/

| Documento | Descripción |
|---|---|
| [git-branch-strategy.md](support-core/git-branch-strategy.md) | Flujo Git estándar |
| [ci-cd-standard.md](support-core/ci-cd-standard.md) | Workflows reutilizables |
| [portal-products-spec.md](support-core/portal-products-spec.md) | Sección Productos del hub |
| [node-migration-plan.md](support-core/node-migration-plan.md) | Node 20 → 22 (plan) |
| [0e3-support-gap-analysis.md](support-core/0e3-support-gap-analysis.md) | Gap analysis Support Core |

### scripts/

| Script | Descripción |
|---|---|
| [security-audit.ps1](scripts/security-audit.ps1) | Checklist automático pre-push |

---

## Riesgos críticos

| Área | Riesgo | Acción |
|---|---|---|
| `e3-gastro-staging` | APK + OTA + billing en un site | No tocar rewrites ni `firebase.gastro-only.json` |
| `nexopos-dc` | POS producción activo | Cutover `nexopos.0es3.com.ar` solo con ventana planificada |
| Repo `0e3-home` | Nombre vs rol portal vs app Flutter | Ver informe consolidación |
| MercadoPago | URLs de callback en env | No cambiar dominios sin actualizar MP |
| Secretos | `.env`, service accounts | Ejecutar `scripts/security-audit.ps1` pre-push |

---

## Próximos pasos

1. Resolver naming portal (`0e3-home` vs `0e3-landing`)
2. Alinear Gastro Git + workflow CI
3. Crear ramas `develop` en repos producto
4. Cutover DNS subdominios `0es3.com.ar`
5. Ver [`reports/FASE-CONSOLIDACION-FINAL.md`](reports/FASE-CONSOLIDACION-FINAL.md)

---

## Índice extendido (legacy)

### architecture/

| Documento | Descripción |
|---|---|
| [AUDITORIA_ECOSISTEMA_0E3_DOMINIOS_HOSTING.md](architecture/AUDITORIA_ECOSISTEMA_0E3_DOMINIOS_HOSTING.md) | Auditoría técnica completa del ecosistema |

### domains/

| Documento | Descripción |
|---|---|
| [oe3-domain-migration-plan.md](domains/oe3-domain-migration-plan.md) | Plan de migración por fases |
| [oe3-subdomain-checklist.md](domains/oe3-subdomain-checklist.md) | Checklist cutover por subdominio |
| [oe3-url-hardcodes-audit.md](domains/oe3-url-hardcodes-audit.md) | URLs hardcodeadas por proyecto |

### firebase/

| Documento | Descripción |
|---|---|
| [oe3-hosting-map.md](firebase/oe3-hosting-map.md) | Mapa de hosting y sites Firebase |

### cloudflare/

| Documento | Descripción |
|---|---|
| [dns-checklist.md](cloudflare/dns-checklist.md) | DNS, SSL y redirects Cloudflare |

### deployments/

| Documento | Descripción |
|---|---|
| [landing-firebase-deploy.md](deployments/landing-firebase-deploy.md) | Resumen deploy landing en Firebase |

### support-core/

| Documento | Descripción |
|---|---|
| [github-organization.md](support-core/github-organization.md) | Organización GitHub ceroes3group |
| [github-repositories.md](support-core/github-repositories.md) | Inventario de repos |
| [coordinacion-repos.md](support-core/coordinacion-repos.md) | Coordinación entre repos |

### reports/

| Documento | Descripción |
|---|---|
| [FASE-0-1-REPORTE-DOMINIOS.md](reports/FASE-0-1-REPORTE-DOMINIOS.md) | Fase 0–1 landing |
| [FASE-2-REPORTE-CONSOLIDADO.md](reports/FASE-2-REPORTE-CONSOLIDADO.md) | Git init + docs Fase 2 |
| [FASE-3-REPORTE-CONSOLIDADO.md](reports/FASE-3-REPORTE-CONSOLIDADO.md) | Merge, push landing, redirect |
| [FASE-DOC-REPORTE-CONSOLIDADO.md](reports/FASE-DOC-REPORTE-CONSOLIDADO.md) | Cierre circuito documentación |

### billing/

| Documento | Descripción |
|---|---|
| [0e3-billing-current-audit.md](billing/0e3-billing-current-audit.md) | Auditoría billing existente por producto |
| [0e3-billing-core-spec.md](billing/0e3-billing-core-spec.md) | Especificación 0E3 Billing Core |
| [mercadopago-integration-plan.md](billing/mercadopago-integration-plan.md) | Plan integración MercadoPago |
| [0e3-entitlements-access-control.md](billing/0e3-entitlements-access-control.md) | Licencias y control de acceso |
| [0e3-billing-rollout-plan.md](billing/0e3-billing-rollout-plan.md) | Plan implementación por producto |
| [0e3-billing-gap-analysis.md](billing/0e3-billing-gap-analysis.md) | Gap analysis pre-implementación |
| [0e3-billing-repo-blueprint.md](billing/0e3-billing-repo-blueprint.md) | Blueprint repo `0e3-billing` |
| [0e3-pos-billing-extraction-plan.md](billing/0e3-pos-billing-extraction-plan.md) | Extracción billing POS → Core |
| [0e3-billing-contracts.md](billing/0e3-billing-contracts.md) | Contratos Firestore compartidos |
| [0e3-shadow-mode-plan.md](billing/0e3-shadow-mode-plan.md) | Shadow mode paralelo |
| [0e3-pos-migration-plan.md](billing/0e3-pos-migration-plan.md) | Migración POS 5 fases |
| [0e3-billing-risk-register.md](billing/0e3-billing-risk-register.md) | Registro de riesgos |

---

## Documentación por producto (repos individuales)

| Producto | Repo | Doc operativa |
|---|---|---|
| Landing | [0e3-landing](https://github.com/ceroes3group/0e3-landing) | `docs/DEPLOY-FIREBASE.md`, `docs/DNS-FIREBASE-CLOUDFLARE-CHECKLIST.md` |
| Aliados | local | `docs/OE3-ARCHITECTURE.md`, `docs/FIREBASE_SETUP.md` |
| HOME | local | `docs/OE3-ARCHITECTURE.md` |
| Gastro | local | `docs/OE3-ARCHITECTURE.md` + docs staging/prod existentes |

---

## Seguridad

Este repo **no debe contener** secretos, tokens, claves privadas, service accounts ni credenciales MercadoPago.  
Solo referencias a nombres de variables y project IDs públicos de Firebase.

## Links institucionales

- Website: https://0e3.com.ar
- Landing: https://github.com/ceroes3group/0e3-landing
- Marca: https://github.com/ceroes3group/0e3-brand
- Roadmap: [`ROADMAP.md`](ROADMAP.md)
