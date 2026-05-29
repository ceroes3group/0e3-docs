# Reporte Fase 0–1 — Migración dominios 0E3

**Fecha:** 2026-05-28  
**Alcance ejecutado:** Fase 0 + Fase 1 (landing). Fases 2–6 solo planificación.  
**Deploy:** ❌ No realizado (esperando aprobación)

---

## A) Estado Git por proyecto

| Proyecto | Git | Branch | Remote | Cambios sin commit | Acción Fase 0 |
|---|---|---|---|---|---|
| `0E3_WORKSPACE/landing` | ✅ | `chore/oe3-domains-architecture` | `ceroes3group/0e3-landing` | ✅ Commiteado | Rama + 2 commits |
| `0E3_WORKSPACE/aliados-comerciales` | ❌ | — | — | — | **No modificado** |
| `oe3_home` | ❌ | — | — | — | **No modificado** |
| `nexopos-dc-multi-tenant` | ✅ | `staging/0e3-migration` | `danielcadiz15/nexopos-dc-multi-tenant` | ⚠️ Muchos (100+ archivos) | **No modificado** |
| `nexopos_gastro_pos` | ❌ | — | — | — | **No modificado** |

---

## B) Branches creadas

| Proyecto | Branch |
|---|---|
| `landing` | `chore/oe3-domains-architecture` |

Otros proyectos: rama no creada (sin Git o cambios masivos pendientes en POS).

---

## C) Commits de respaldo realizados

### `0e3-landing` (landing)

1. **`80b87bd`** — `chore: backup pre domain architecture migration`  
   Preserva: Firebase export, EcosystemAccess, firebase.json, .firebaserc

2. **`feat(landing): canonical 0e3.com.ar and /apps catalog routes`** (HEAD)  
   Fase 1 completa

---

## D) Archivos modificados (Fase 1 — landing)

| Archivo | Cambio |
|---|---|
| `src/lib/constants.ts` | Canónico `0e3.com.ar`, `domains`, `liveUrls`, `appPages` |
| `src/app/apps/page.tsx` | Catálogo `/apps/` |
| `src/app/apps/nexopos/page.tsx` | Ficha NexoPOS |
| `src/app/apps/gastro/page.tsx` | Ficha Gastro |
| `src/app/apps/aliados/page.tsx` | Ficha Aliados |
| `src/app/apps/home/page.tsx` | Ficha HOME |
| `src/components/AppProductPage.tsx` | Layout ficha producto + badge beta |
| `src/components/Hero.tsx` | Nav Apps, logo → `/`, CTAs |
| `src/components/Products.tsx` | Links a fichas |
| `src/components/EcosystemAccess.tsx` | URLs live + notas destino DNS |
| `src/components/Contact.tsx` | Sin LinkedIn/WhatsApp `#` |
| `src/components/Footer.tsx` | Link Apps |
| `docs/DEPLOY-FIREBASE.md` | Política `0e3.com.ar` |
| `docs/DNS-FIREBASE-CLOUDFLARE-CHECKLIST.md` | **Nuevo** — Fase 2 manual |
| `README.md` | Dominio canónico |
| `.gitignore` | Ignorar `.firebase/` |

---

## E) Archivos NO modificados (por seguridad)

- `0E3_WORKSPACE/aliados-comerciales/**` (sin Git)
- `oe3_home/**` (sin Git)
- `nexopos-dc-multi-tenant/**` (POS prod — cambios masivos preexistentes)
- `nexopos_gastro_pos/**` (sin Git)
- `nexopos_gastro_pos_revision_package/**`
- `firebase.gastro-only.json`
- Firebase Console / Cloudflare

---

## F) Diff resumido

- **~891 líneas** agregadas/modificadas en landing (2 commits totales en rama)
- Dominio canónico: `0es3.com.ar` → **`0e3.com.ar`**
- **6 rutas estáticas** nuevas: `/apps/` + 4 fichas
- Links externos: usan **`.web.app` operativos** con nota de dominio objetivo
- Gastro: eliminado link a `e3-gastro-web.web.app` (404) → staging funcional

---

## G) Build results

```
npm run build:firebase → ✅ OK

Route (app)
┌ ○ /
├ ○ /apps
├ ○ /apps/aliados
├ ○ /apps/gastro
├ ○ /apps/home
└ ○ /apps/nexopos

out/apps/nexopos/index.html → ✅
out/apps/index.html → ✅
```

---

## H) Riesgos detectados

| Riesgo | Nivel | Notas |
|---|---|---|
| 3 proyectos sin Git | 🔴 | aliados, home, gastro — no se pudieron versionar |
| POS branch con 100+ cambios | 🔴 | No tocar hasta ordenar commits |
| Links usan `.web.app` temporal | 🟢 | Intencional hasta DNS Fase 2–3 |
| Site ID sigue `0es3-com-ar` | 🟢 | Correcto — no renombrar |
| Gastro OTA/billing | 🔴 | No tocado |

---

## I) Pasos manuales Firebase (Fase 2 — humano)

Ver: `landing/docs/DNS-FIREBASE-CLOUDFLARE-CHECKLIST.md`

1. Add custom domain `0e3.com.ar` en site `0es3-com-ar`
2. DNS TXT + A/CNAME
3. SSL automático
4. Validar `https://0e3.com.ar`

---

## J) Pasos manuales Cloudflare (Fase 2 — humano)

1. Redirect 301: `0es3.com.ar/*` → `https://0e3.com.ar/$1`
2. Redirect 301: `www.0es3.com.ar/*` → `https://0e3.com.ar/$1`
3. Proxy gris durante verificación SSL

---

## K) Orden recomendado de deploys (post-aprobación)

1. **Landing** — `npm run deploy:hosting` en rama `chore/oe3-domains-architecture`
2. DNS `0e3.com.ar` + redirects `0es3.com.ar`
3. HOME + Aliados (subdominios)
4. Gastro web staging DNS
5. POS cutover (ventana controlada)
6. Gastro APK domain (último)

---

## L) Plan de rollback

```powershell
cd C:\Users\Asus\Proyectos\0E3_WORKSPACE\landing
git checkout main
npm run deploy:hosting   # redeploy versión anterior
```

DNS: quitar custom domain en Firebase; desactivar rules Cloudflare.  
`.web.app` sigue activo: `https://0es3-com-ar.web.app`

---

## M) Comandos deploy (NO ejecutados)

```powershell
# Landing (cuando apruebes)
cd C:\Users\Asus\Proyectos\0E3_WORKSPACE\landing
git push -u origin chore/oe3-domains-architecture   # opcional PR
npm run deploy:hosting
```

---

## N) Aprobaciones humanas requeridas

| Item | Requiere OK |
|---|---|
| Deploy landing Fase 1 | ✅ Usuario |
| DNS `0e3.com.ar` Firebase | ✅ Usuario |
| Redirect Cloudflare `0es3.com.ar` | ✅ Usuario |
| Inicializar Git en aliados/home/gastro | ✅ Usuario |
| POS cutover | ✅ Usuario + ventana |
| Gastro OTA/billing changes | ✅ Usuario explícito |
| MP_BACK_URL changes | ✅ Usuario explícito |

---

## Documentos relacionados

| Archivo | Ubicación |
|---|---|
| Auditoría completa | `0E3_WORKSPACE/docs/AUDITORIA_ECOSISTEMA_0E3_DOMINIOS_HOSTING.md` |
| Plan migración | `0E3_WORKSPACE/docs/oe3-domain-migration-plan.md` |
| DNS checklist | `0E3_WORKSPACE/landing/docs/DNS-FIREBASE-CLOUDFLARE-CHECKLIST.md` |

---

**Estado:** ⏸ Detenido esperando aprobación para deploy y Fase 2.
