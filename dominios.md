# Dominios — Ecosistema 0E3

**Actualizado:** 2026-05-27  
**Apex objetivo:** `0es3.com.ar` (portal corporativo)  
**Regla:** un subdominio = un producto = un deploy Firebase independiente.

---

## Mapa objetivo (DNS)

| Dominio | Rol | Repo | Firebase project | Site ID |
|---|---|---|---|---|
| **`0es3.com.ar`** | Portal corporativo (hub) | `0e3-home` / transición `0e3-landing` | `oe3-institutional` | `0es3-com-ar` * |
| **`www.0es3.com.ar`** | Redirect → apex | Cloudflare | — | — |
| **`aliados.0es3.com.ar`** | Aliados Comerciales | `0e3-aliados-comerciales` | `oe3-aliados-comerciales` | default |
| **`gastro.0es3.com.ar`** | Gastro prod (web/APK) | `0e3-gastro` | `e3-gastro` | `e3-gastro` / `e3-gastro-web` |
| **`nexopos.0es3.com.ar`** | NexoPOS / 0E3 POS | `nexopos-dc` | `nexopos-dc` | `nexopos-dc` |
| **`apps.0es3.com.ar`** | Catálogo / launcher apps | portal o redirect | TBD | TBD |
| **`docs.0es3.com.ar`** | Documentación pública | `0e3-docs` | TBD | TBD |

\* Site ID histórico `0es3-com-ar` — **no renombrar** en Firebase.

---

## Estado actual (2026-05-27)

| Dominio | Estado |
|---|---|
| `0e3.com.ar` | ✅ Live — landing Next.js (`0e3-landing`) |
| `0es3.com.ar` | ✅ Redirect 301 → `0e3.com.ar` (Cloudflare) |
| Subdominios producto | ⏸ Pendientes cutover |
| URLs operativas | `.web.app` por producto |

### Migración apex portal

| Paso | Acción |
|---|---|
| 1 | Decidir cutover: `0es3.com.ar` como apex canónico del hub |
| 2 | Invertir o reemplazar redirect Cloudflare (`0es3` ↔ `0e3`) |
| 3 | Conectar custom domain en Firebase Hosting |
| 4 | Actualizar canonical/metadata en portal |
| 5 | Mantener redirect legacy `0e3.com.ar` → `0es3.com.ar` si aplica |

---

## Subdominios staging (referencia)

| Dominio | Uso | Riesgo |
|---|---|---|
| `staging.gastro.0es3.com.ar` | Gastro web PWA staging | Medio |
| `staging.0es3.com.ar` | Gastro APK/OTA/billing | 🔴 Crítico |
| `demo.0e3.com.ar` | POS staging | Bajo |

Detalle histórico: [`domains/oe3-subdomain-checklist.md`](domains/oe3-subdomain-checklist.md)

---

## Cloudflare — plantilla

| Tipo | Nombre | Destino |
|---|---|---|
| CNAME/A | `@` | Firebase Hosting (portal) |
| CNAME | `aliados` | Firebase Aliados |
| CNAME | `gastro` | Firebase Gastro prod |
| CNAME | `nexopos` | Firebase POS |
| CNAME | `docs` | Firebase docs / GitHub Pages |
| Redirect | `www` | apex |

Checklist operativo: [`cloudflare/dns-checklist.md`](cloudflare/dns-checklist.md)

---

## Qué evitar

- ❌ Servir Aliados + Gastro desde el mismo `firebase.json` / site
- ❌ Mezclar billing/OTA con portal institucional
- ❌ Cambiar `MP_BACK_URL` sin actualizar MercadoPago
- ❌ Renombrar project IDs Firebase en producción
