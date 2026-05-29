# Checklist técnico — Subdominios 0E3 (Fase 2C)

**Estado:** preparación solamente — **NO conectar aún**

---

## 1. `pos.0e3.com.ar` — NexoPOS / 0E3 POS

| Item | Detalle |
|---|---|
| Firebase project | `nexopos-dc` |
| Hosting site | `nexopos-dc` |
| URL actual | https://nexopos-dc.web.app |
| DNS | CNAME `pos` → Firebase Hosting (valor desde Console) |
| Auth authorized domains | Agregar `pos.0e3.com.ar` en Firebase Auth |
| Variables env | `REACT_APP_PUBLIC_APP_URL`, `PUBLIC_APP_URL` (Functions MP) |
| Archivos código | `client/src/config/appEnvironment.js`, `functions/routes/billing-mercadopago.routes.js`, `client/capacitor.config.ts`, Android MainActivity |
| Rebuild | ✅ `client` npm build + deploy hosting; posible functions |
| Riesgo | 🔴 **Crítico** — pagos MP, emails auth, multi-tenant, APK caja |
| Rollback | Revert env a `nexopos-dc.web.app`; quitar custom domain; redeploy |

---

## 2. `home.0e3.com.ar` — 0E3 HOME

| Item | Detalle |
|---|---|
| Firebase project | `oe3-home-beta` |
| Hosting site | default (`oe3-home-beta`) |
| URL actual | https://oe3-home-beta.web.app |
| DNS | CNAME `home` → Firebase |
| Auth authorized domains | Agregar `home.0e3.com.ar` |
| Variables env | Ninguna pública crítica detectada |
| Archivos | `lib/firebase_options.dart` (authDomain sigue `*.firebaseapp.com`) |
| Rebuild | `flutter build web` + `firebase deploy --only hosting` |
| Riesgo | 🟡 Beta — bajo impacto prod |
| Rollback | Quitar custom domain; `.web.app` sigue activo |

---

## 3. `aliados.0e3.com.ar` — Aliados Comerciales

| Item | Detalle |
|---|---|
| Firebase project | `oe3-aliados-comerciales` |
| Hosting site | default |
| URL actual | https://oe3-aliados-comerciales.web.app |
| DNS | CNAME `aliados` → Firebase |
| Auth authorized domains | Agregar `aliados.0e3.com.ar` |
| Variables env | `VITE_*` en `web/.env.production` (no commiteado) |
| Archivos | `web/src/lib/firebase.ts`, `web/.env.production` |
| Rebuild | `npm run deploy:hosting` |
| Riesgo | 🟡 Staging comercial — Functions WhatsApp separadas |
| Rollback | Custom domain off; `.web.app` activo |

---

## 4. `gastro.0e3.com.ar` — Gastro producción (futuro)

| Item | Detalle |
|---|---|
| Firebase project | `e3-gastro` |
| Hosting site web | `e3-gastro-web` |
| Hosting site APK | `e3-gastro` |
| URL actual | 404 (sin deploy prod) |
| DNS | **No conectar hasta deploy prod** |
| Auth | `e3-gastro` / `e3-gastro.firebaseapp.com` |
| Riesgo | 🟡 Medio — prod vacío hoy |
| Rollback | N/A hasta exista deploy |

---

## 5. `staging.gastro.0e3.com.ar` — Gastro web staging

| Item | Detalle |
|---|---|
| Firebase project | `e3-gastro-staging` |
| Hosting site | `e3-gastro-staging-web` |
| URL actual | https://e3-gastro-staging-web.web.app |
| DNS | CNAME `staging.gastro` → Firebase |
| Auth authorized domains | Agregar subdominio |
| Variables | Ninguna URL hardcoded crítica en web build |
| Rebuild | `scripts/deploy-staging-web.ps1` |
| Riesgo | 🟡 Solo web PWA — **no tocar** site APK |
| Rollback | DNS off; `e3-gastro-staging-web.web.app` sigue |

---

## 6. `staging.0e3.com.ar` — APK / OTA / billing (⚠️ CRÍTICO)

| Item | Detalle |
|---|---|
| Firebase project | `e3-gastro-staging` |
| Hosting site | `e3-gastro-staging` (**NO** `e3-gastro-staging-web`) |
| URL actual | https://e3-gastro-staging.web.app |
| Endpoints críticos | `/apk`, `/app-updates/android/latest.json`, `/billing/` |
| DNS | CNAME `staging` → site APK |
| Auth | Menor — billing usa MP back_urls |
| Variables | `MP_BACK_URL`, `APK_MANIFEST_BASE_URL` |
| Archivos | `app_environment.dart`, `firebase.gastro-only.json`, `deploy-staging-apk.ps1` |
| Rebuild | Solo tras cambiar env + **aprobar** + redeploy APK hosting |
| Riesgo | 🔴 **CRÍTICO** — tablets instaladas, OTA, MercadoPago |
| Rollback | Mantener `e3-gastro-staging.web.app`; revert `APK_MANIFEST_BASE_URL` |

---

## Matriz de aprobación humana

| Subdominio | Conectar DNS | Cambiar código | Deploy |
|---|---|---|---|
| `home.*` | Aprobación | Opcional | Tras DNS |
| `aliados.*` | Aprobación | `.env.production` | Tras DNS |
| `staging.gastro.*` | Aprobación | No requerido | Verificar |
| `pos.*` | **Ventana planificada** | **Sí** | **Sí** |
| `staging.*` (APK) | **Explícita** | **Sí** | **Sí** |
| `gastro.*` prod | Cuando exista deploy | Sí | Sí |
