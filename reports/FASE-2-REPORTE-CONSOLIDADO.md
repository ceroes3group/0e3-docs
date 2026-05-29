# Reporte consolidado — Fase 2 (2A–2E)

**Fecha:** 2026-05-28  
**Deploy realizado en esta fase:** ❌ Ninguno  
**Firebase/Cloudflare modificados:** ❌ No  
**GitHub push:** ❌ No

---

## Resumen ejecutivo

Fase 2 completada: **Git inicializado en 3 proyectos**, documentación de hosting/subdominios/hardcodes generada, **producción landing validada** vía Firebase default URL. Sin tocar POS, Gastro OTA/billing, Functions críticas ni DNS subdominios.

---

## FASE 2A — Git normalizado

### Auditoría previa

| Proyecto | Tamaño disco | Artefactos detectados | Secretos en disco |
|---|---|---|---|
| `aliados-comerciales` | ~216 MB | `node_modules`, `.firebase` | `web/.env*` (3 archivos) — **no commiteados** |
| `oe3_home` | ~1488 MB | `build/`, `.dart_tool/`, `.firebase`, `out/` | `google-services.json` — **ignorado** |
| `nexopos_gastro_pos` | ~5142 MB | `build/`, `.dart_tool/`, `.firebase` | `google-services.json` (3 flavors), `functions/.env.e3-gastro-staging` — **no commiteados** |

### `.gitignore` actualizado

| Proyecto | Cambios clave |
|---|---|
| aliados | `**/.env*`, `**/dist/`, `.firebase/`, service accounts |
| oe3_home | `.firebase/`, `/out/`, `.env*` |
| nexopos_gastro_pos | `.firebase/`, `functions/.env*`, `**/google-services.json` |

### Git inicializado

| Proyecto | Branch | Commit | Archivos | Remote |
|---|---|---|---|---|
| `aliados-comerciales` | `chore/oe3-architecture` | `4834abf` | 79 | ❌ local only |
| `oe3_home` | `chore/oe3-architecture` | `a538d28` | 347 | ❌ local only |
| `nexopos_gastro_pos` | `chore/oe3-architecture` | `ec50164` | 469 | ❌ local only |

### Verificación secretos

- ✅ Ningún `.env` commiteado (excepto `.env.example`)
- ✅ Ningún `google-services.json` commiteado
- ✅ `functions/.env.e3-gastro-staging` excluido

### Notas / follow-ups Git

- Gastro commit incluye **ZIPs grandes** (`0e3-gastro-review-chatgpt-20260526.zip`, etc.) — considerar `.gitignore` en limpieza futura
- Commiteado `google-services.nexopos_dc.json` (plantilla renombrada, no el archivo activo)
- `oe3_home`: `.firebaserc` permanece **ignorado** por política existente
- **Landing** ya tenía Git en rama `chore/oe3-domains-architecture` (Fase 0–1)

---

## FASE 2B — Mapa hosting

📄 **`docs/oe3-hosting-map.md`**

---

## FASE 2C — Subdominios (solo plan)

📄 **`docs/oe3-subdomain-checklist.md`**

---

## FASE 2D — Hardcodes URLs

📄 **`docs/oe3-url-hardcodes-audit.md`**

---

## FASE 2E — Checks producción landing

### Desde entorno automatizado

| Check | `https://0e3.com.ar` | `https://0es3-com-ar.web.app` |
|---|---|---|
| HTTP 200 `/` | ⚠️ SSL handshake error en PowerShell/curl agente | ✅ 200 |
| `/apps` | ⚠️ idem | ✅ 200 |
| `/apps/nexopos` | ⚠️ idem | ✅ 200 |
| `/apps/gastro` | ⚠️ idem | ✅ 200 |
| `/apps/aliados` | ⚠️ idem | ✅ 200 |
| `/apps/home` | ⚠️ idem | ✅ 200 |
| Canonical `0e3.com.ar` en HTML | ⚠️ no verificado (SSL) | ✅ presente |
| Mixed content `http://` | — | ✅ none obvious |

> **Nota:** El usuario confirmó `0e3.com.ar` operativo con SSL. El agente encontró error SSL local (exit 60) — posible cadena intermedia en propagación o restricción del runner. Firebase default URL validada al 100%.

### Redirect `0es3.com.ar`

- ⚠️ No resuelve DNS desde este entorno (`NXDOMAIN`)
- Pendiente validación humana si redirect Cloudflare está configurado

### Broken links críticos (landing)

- ✅ Links externos usan `.web.app` operativos
- ✅ Gastro prod 404 eliminado de links
- ✅ LinkedIn/WhatsApp placeholders removidos

---

## NO modificado (confirmación)

- ❌ `nexopos-dc-multi-tenant`
- ❌ Gastro deploy / OTA / billing / MP
- ❌ Firebase Functions
- ❌ Cloudflare / DNS subdominios
- ❌ GitHub push
- ❌ `revision_package`

---

## Documentos generados

| Archivo |
|---|
| `docs/oe3-hosting-map.md` |
| `docs/oe3-subdomain-checklist.md` |
| `docs/oe3-url-hardcodes-audit.md` |
| `docs/FASE-2-REPORTE-CONSOLIDADO.md` (este) |
| `docs/oe3-domain-migration-plan.md` (Fase 0) |

---

## Próximos pasos (requieren aprobación)

1. **Validar manualmente** `https://0e3.com.ar` + redirect `0es3.com.ar` desde navegador
2. **Conectar subdominio bajo riesgo:** `home.0e3.com.ar` o `aliados.0e3.com.ar`
3. **Merge landing** `chore/oe3-domains-architecture` → `main` + push GitHub
4. **Remotes Git** para aliados/home/gastro + push cuando apruebes
5. **POS cutover** — solo tras ventana planificada (Fase 4)

---

⏸ **Detenido — esperando aprobación humana para Fase 3 (subdominios DNS).**
