# Auditoría de URLs hardcodeadas — Ecosistema 0E3

**Fecha:** 2026-05-28  
**Alcance:** código fuente y configs (excl. `node_modules`, `build/`, `.dart_tool/`)

---

## Clasificación

| Clase | Significado |
|---|---|
| ✅ **Seguro cambiar** | Docs, landing links, metadata |
| ⚠️ **Peligroso** | Requiere rebuild + deploy coordinado |
| 🔴 **OTA** | Tablets leen manifiesto JSON |
| 🔴 **Billing** | MercadoPago back_urls |
| 🔴 **Auth** | authDomain / authorized domains |
| 🔴 **APK instalada** | URL embebida en builds desplegados |

---

## Landing (`0E3_WORKSPACE/landing`)

| Archivo | URL / dominio | Clase | Notas |
|---|---|---|---|
| `src/lib/constants.ts` | `site.url` = `0e3.com.ar` | ✅ | Canónico correcto |
| `src/lib/constants.ts` | `liveUrls.*` = `.web.app` | ✅ | Fallback hasta DNS subdominios |
| `src/lib/constants.ts` | `domains.*` = subdominios objetivo | ✅ | Documentación destino |

**Estado:** alineado post Fase 1.

---

## NexoPOS (`nexopos-dc-multi-tenant`) — NO MODIFICADO

| Archivo | Hardcode | Clase |
|---|---|---|
| `client/src/config/appEnvironment.js` | `nexopos-dc.web.app`, `nexopos-dc-staging.web.app` | ⚠️ + 🔴 Auth emails |
| `functions/routes/billing-mercadopago.routes.js` | `PUBLIC_APP_URL` fallback `nexopos-dc.web.app` | 🔴 Billing |
| `client/src/firebase/config.js` | `nexopos-dc.firebaseapp.com` | 🔴 Auth |
| `client/capacitor.config.ts` | `nexopos-dc.web.app` | 🔴 APK caja |
| `client/.env.staging` | `REACT_APP_PUBLIC_APP_URL` staging | ⚠️ |

**Cutover objetivo:** `pos.0e3.com.ar` vía env, no hardcode directo.

---

## Gastro (`nexopos_gastro_pos`) — NO MODIFICADO

| Archivo | Hardcode | Clase |
|---|---|---|
| `lib/core/config/app_environment.dart` | `e3-gastro-staging.web.app/.../latest.json` | 🔴 **OTA** |
| `lib/core/config/app_environment.dart` | `e3-gastro.web.app/.../latest.json` | 🔴 OTA prod |
| `lib/core/config/app_environment.dart` | `nexopos-gastro-pos.web.app/...` | 🔴 OTA dev |
| `functions/.env.e3-gastro-staging` | `MP_BACK_URL=.../billing/` | 🔴 **Billing** (gitignored) |
| `functions/.env.staging.example` | ejemplo MP_BACK_URL | ✅ doc |
| `scripts/deploy-staging-apk.ps1` | `APK_MANIFEST_BASE_URL` default | 🔴 OTA |
| `lib/firebase_options*.dart` | `*.firebaseapp.com` | 🔴 Auth |
| `docs/domain-setup.md` | mix `0e3` / `0es3` | ✅ doc — reconciliar |

**Regla:** NO cambiar OTA/billing sin aprobación explícita.

---

## 0E3 HOME (`oe3_home`)

| Archivo | Hardcode | Clase |
|---|---|---|
| `lib/firebase_options.dart` | `oe3-home-beta.firebaseapp.com` | 🔴 Auth (normal Firebase) |

**Cutover:** solo DNS custom + authorized domain; authDomain puede permanecer.

---

## Aliados (`aliados-comerciales`)

| Archivo | Hardcode | Clase |
|---|---|---|
| `web/.env.production` | `oe3-aliados-comerciales.firebaseapp.com` | 🔴 Auth (gitignored) |
| `README.md` | `oe3-aliados-comerciales.web.app` | ✅ doc |

---

## Resumen por patrón

### `*.web.app` en runtime productivo

| URL | Usado por | Clase cambio |
|---|---|---|
| `nexopos-dc.web.app` | POS prod | 🔴 Billing/Auth |
| `e3-gastro-staging.web.app` | OTA + billing | 🔴 **NO TOCAR** |
| `e3-gastro-staging-web.web.app` | Gastro web stg | ⚠️ DNS only OK |
| `oe3-home-beta.web.app` | HOME | ⚠️ |
| `oe3-aliados-comerciales.web.app` | Aliados | ⚠️ |
| `0es3-com-ar.web.app` | Landing | ✅ mantiene compat |

### Dominios `0e3.com.ar` / `0es3.com.ar`

| Ubicación | Valor | Estado |
|---|---|---|
| Landing `constants.ts` | `0e3.com.ar` canónico | ✅ |
| Workspace `.env.example` | `0e3.com.ar` | ✅ |
| Gastro `domain-setup.md` | mixto | ⚠️ doc legacy |
| DEPLOY-VERCEL.md (landing) | `0e3.com.ar` viejo doc | ⚠️ menor |

### `localhost`

| Proyecto | Uso | Clase |
|---|---|---|
| Aliados emulators | `127.0.0.1:5001` | ✅ dev only |
| POS `.env.emulator*` | localhost:3000 | ✅ dev only |

---

## Orden seguro de cambio de URLs

1. ✅ Landing metadata y links (hecho)
2. DNS subdominios bajo riesgo (home, aliados, staging.gastro web)
3. Env vars POS + rebuild (ventana)
4. OTA manifest URL + redeploy APK (último, aprobación)

---

## Comando útil para re-auditar

```powershell
rg -g '!node_modules' -g '!build' -g '!.dart_tool' -g '!out' \
  'web\.app|firebaseapp\.com|0e3\.com\.ar|0es3\.com\.ar' \
  C:\Users\Asus\Proyectos\0E3_WORKSPACE \
  C:\Users\Asus\Proyectos\oe3_home \
  C:\Users\Asus\Proyectos\nexopos_gastro_pos \
  C:\Users\Asus\Proyectos\nexopos-dc-multi-tenant
```
