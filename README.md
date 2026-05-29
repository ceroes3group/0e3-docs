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
| [0e3-landing](https://github.com/ceroes3group/0e3-landing) | ✅ Publicado | `main` @ `dadfe70` |
| `0e3-docs` | ⏸ Local only | `main` |
| `0e3-aliados-comerciales` | ⏸ Local only | `chore/oe3-architecture` |
| `0e3-home` | ⏸ Local only | `chore/oe3-architecture` |
| `0e3-gastro` | ⏸ Local only | `chore/oe3-architecture` |

---

## Decisiones tomadas

1. **`0e3.com.ar`** es el dominio canónico institucional (no `0es3.com.ar`).
2. **`0es3.com.ar`** actúa solo como alias con redirect 301 en Cloudflare.
3. Landing export estático Next.js → Firebase Hosting site **`0es3-com-ar`** (ID no renombrable).
4. Cada producto mantiene su **proyecto Firebase separado**; no unificar sites Gastro APK vs web.
5. Git inicializado localmente en aliados, HOME y Gastro; push pendiente de aprobación.
6. POS, Gastro prod, OTA, billing y MercadoPago **fuera de alcance** sin plan explícito.

---

## Riesgos críticos

| Área | Riesgo | Acción |
|---|---|---|
| `e3-gastro-staging` | APK + OTA + billing en un site | No tocar rewrites ni `firebase.gastro-only.json` |
| `nexopos-dc` | POS producción activo | Cutover `pos.0e3.com.ar` solo con ventana planificada |
| MercadoPago | URLs de callback en env | No cambiar dominios sin actualizar MP |
| Gastro Git | ZIPs ~5.5 MB en repo | Eliminar del índice antes del primer push |
| Secretos | `.env`, service accounts | Nunca commitear; ver `.gitignore` por proyecto |

---

## Próximos pasos

1. Aprobar push de este repo → `ceroes3group/0e3-docs`
2. Crear remotes y push aliados / home / gastro
3. Cutover DNS bajo riesgo: `home.0e3.com.ar`, `aliados.0e3.com.ar`
4. Cutover Gastro web staging (riesgo medio)
5. Cutover POS y `staging.0e3.com.ar` (alto/crítico)

---

## Índice de documentación

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
