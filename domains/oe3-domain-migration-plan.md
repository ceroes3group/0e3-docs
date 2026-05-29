# Plan de migración de dominios 0E3

**Base:** [`../architecture/AUDITORIA_ECOSISTEMA_0E3_DOMINIOS_HOSTING.md`](../architecture/AUDITORIA_ECOSISTEMA_0E3_DOMINIOS_HOSTING.md)  
**Fecha inicio:** 2026-05-28  
**Actualizado:** 2026-05-27  
**Estado:** Fases 0–3 landing completadas. Push GitHub landing ✅. Redirect `0es3.com.ar` ✅. Fases 4–6 pendientes.

---

## Decisión de arquitectura

| Rol | Dominio |
|---|---|
| Raíz institucional | `https://0e3.com.ar` |
| Alias redirect 301 | `https://0es3.com.ar` → `0e3.com.ar` |
| POS / NexoPOS | `https://pos.0e3.com.ar` |
| 0E3 HOME | `https://home.0e3.com.ar` |
| Aliados Comerciales | `https://aliados.0e3.com.ar` |
| Gastro prod (futuro) | `https://gastro.0e3.com.ar` |
| Gastro web staging | `https://staging.gastro.0e3.com.ar` |
| APK/OTA/billing staging | `https://staging.0e3.com.ar` ⚠️ |
| Docs (futuro) | `https://docs.0e3.com.ar` |

**Regla:** No renombrar Firebase project IDs ni site IDs (ej. `0es3-com-ar`).

---

## Mapa actual → deseado

| Producto | URL hoy | Dominio objetivo |
|---|---|---|
| Landing | `0es3-com-ar.web.app` | `0e3.com.ar` |
| POS | `nexopos-dc.web.app` | `pos.0e3.com.ar` |
| HOME | `oe3-home-beta.web.app` | `home.0e3.com.ar` |
| Aliados | `oe3-aliados-comerciales.web.app` | `aliados.0e3.com.ar` |
| Gastro web stg | `e3-gastro-staging-web.web.app` | `staging.gastro.0e3.com.ar` |
| Gastro APK stg | `e3-gastro-staging.web.app` | `staging.0e3.com.ar` |

---

## Fases

| Fase | Alcance | Estado |
|---|---|---|
| 0 | Git, backup, ramas | ✅ Landing |
| 1 | Landing canónico + `/apps/*` | ✅ Código (sin deploy) |
| 2 | DNS Firebase + Cloudflare landing | 📋 Plan listo |
| 3 | Subdominios producto | 📋 Plan pendiente |
| 4 | POS cutover | 📋 Read-only plan |
| 5 | Gastro (extremo cuidado) | 📋 Read-only plan |
| 6 | Aliados + HOME | 📋 Checklist |
| 7 | Deploys aprobados | ⏸ Esperando humano |

---

## Fase 2 — Instrucciones manuales

Ver: `landing/docs/DNS-FIREBASE-CLOUDFLARE-CHECKLIST.md`

---

## Fase 3 — Subdominios producto (preparación)

### `pos.0e3.com.ar`

| Item | Valor |
|---|---|
| Firebase project | `nexopos-dc` |
| Site | `nexopos-dc` |
| URL hoy | `nexopos-dc.web.app` |
| Archivos a modificar (futuro) | `client/src/config/appEnvironment.js`, `.env*`, `functions/billing-mercadopago.routes.js`, `capacitor.config.ts` |
| Riesgo | 🔴 Pagos, auth, multi-tenant, APK caja |
| Rebuild | Sí (client + posible functions) |
| Auth authorized domain | Agregar `pos.0e3.com.ar` en Firebase Auth |

### `home.0e3.com.ar`

| Item | Valor |
|---|---|
| Firebase project | `oe3-home-beta` |
| Site | default |
| URL hoy | `oe3-home-beta.web.app` |
| Archivos | README, docs; posible `firebase_options.dart` authDomain no cambia |
| Riesgo | 🟡 Beta |
| Rebuild | `flutter build web` + deploy hosting |

### `aliados.0e3.com.ar`

| Item | Valor |
|---|---|
| Firebase project | `oe3-aliados-comerciales` |
| URL hoy | `oe3-aliados-comerciales.web.app` |
| Archivos | `web/.env.production`, Vite env |
| Riesgo | 🟡 Módulo aparte — **no modificado en Fase 1** |
| Git | ❌ Sin repo — inicializar antes de cambios |

### `staging.gastro.0e3.com.ar`

| Item | Valor |
|---|---|
| Firebase project | `e3-gastro-staging` |
| Site | `e3-gastro-staging-web` |
| URL hoy | `e3-gastro-staging-web.web.app` |
| Riesgo | 🟡 Staging web only |
| Rebuild | `flutter build web` + deploy web staging config |

### `staging.0e3.com.ar` (APK/OTA/billing)

| Item | Valor |
|---|---|
| Firebase project | `e3-gastro-staging` |
| Site | `e3-gastro-staging` |
| URL hoy | `e3-gastro-staging.web.app` |
| Riesgo | 🔴 **CRÍTICO** — tablets, OTA, MercadoPago |
| NO tocar | `firebase.gastro-only.json`, rewrites OTA, `MP_BACK_URL` sin aprobación |

---

## Fase 4 — POS cutover (plan, no ejecutado)

Archivos con `nexopos-dc.web.app`:

- `nexopos-dc-multi-tenant/client/src/config/appEnvironment.js`
- `nexopos-dc-multi-tenant/functions/routes/billing-mercadopago.routes.js`
- `nexopos-dc-multi-tenant/client/capacitor.config.ts`
- `nexopos-dc-multi-tenant/client/android/.../MainActivity.java` (si aplica)

Variable clave: `REACT_APP_PUBLIC_APP_URL`, `PUBLIC_APP_URL`

**Branch actual POS:** `staging/0e3-migration` (muchos cambios sin commit — no tocar)

---

## Fase 5 — Gastro (plan, no ejecutado)

**NO modificar sin aprobación:**

- `firebase.gastro-only.json`
- `lib/core/config/app_environment.dart` → `updateManifestUrl`
- `functions/.env.e3-gastro-staging` → `MP_BACK_URL`
- `scripts/deploy-staging-apk.ps1`

Matriz:

| Componente | ¿Cambiar? | Dependencia |
|---|---|---|
| Web staging site | ✅ DNS only (Fase 3) | PC navegador |
| APK site rewrites | ❌ | Tablets Android |
| OTA JSON path | ❌ | Login "Actualizar app" |
| Billing `/billing/` | ❌ | MercadoPago |

---

## Fase 6 — Aliados y HOME (checklist)

### Aliados

- [ ] Inicializar Git en `aliados-comerciales`
- [ ] Rama `chore/oe3-domains-architecture`
- [ ] Revisar `web/.env.production` URLs
- [ ] Agregar `aliados.0e3.com.ar` en Firebase Auth
- [ ] Deploy hosting tras DNS

### HOME

- [ ] Inicializar Git en `oe3_home`
- [ ] Documentar URL canónica
- [ ] Custom domain `home.0e3.com.ar`
- [ ] `flutter build web` + deploy

---

## Orden de deploys recomendado

1. Landing → Firebase (tras aprobación Fase 1)
2. DNS `0e3.com.ar` + redirect `0es3.com.ar`
3. HOME + Aliados (bajo riesgo)
4. Gastro web staging DNS
5. POS cutover (alto riesgo, ventana controlada)
6. Gastro APK custom domain (último, con tablets en cuenta)

---

## Rollback

| Nivel | Acción |
|---|---|
| Landing | Redeploy commit anterior en rama; quitar custom domain |
| DNS | Desactivar rules Cloudflare; Firebase sigue en `.web.app` |
| POS | Revert env `REACT_APP_PUBLIC_APP_URL` a `nexopos-dc.web.app` |
| Gastro OTA | **No cambiar** — rollback solo redeploy versión anterior hosting |

---

## Proyectos sin Git (no modificados)

| Proyecto | Acción propuesta |
|---|---|
| `aliados-comerciales` | `git init` + remote GitHub |
| `oe3_home` | `git init` + remote |
| `nexopos_gastro_pos` | `git init` urgente |

---

*Documento vivo — actualizar tras cada fase aprobada.*
