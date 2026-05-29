# Cloudflare — DNS, SSL y redirects 0E3

**Actualizado:** 2026-05-27  
**Alcance:** instrucciones y estado; cambios en Cloudflare solo con aprobación explícita.

Documentación operativa detallada (checklist paso a paso): repo landing  
https://github.com/ceroes3group/0e3-landing/blob/main/docs/DNS-FIREBASE-CLOUDFLARE-CHECKLIST.md

Auditoría base: [`../architecture/AUDITORIA_ECOSISTEMA_0E3_DOMINIOS_HOSTING.md`](../architecture/AUDITORIA_ECOSISTEMA_0E3_DOMINIOS_HOSTING.md)

---

## Estado actual

| Dominio | Estado | Notas |
|---|---|---|
| `0e3.com.ar` | ✅ Live + SSL | Custom domain Firebase → site `0es3-com-ar` |
| `0es3.com.ar` | ✅ Redirect 301 | Configurado manualmente → `https://0e3.com.ar` |
| `www.0es3.com.ar` | ✅ Redirect 301 | Hacia apex canónico |
| Subdominios producto | ⏸ Pendientes | Ver [`../domains/oe3-subdomain-checklist.md`](../domains/oe3-subdomain-checklist.md) |

---

## Redirect alias `0es3.com.ar`

En Cloudflare → **Rules → Redirect Rules**:

| Origen | Destino | Código |
|---|---|---|
| `0es3.com.ar/*` | `https://0e3.com.ar/$1` | 301 |
| `www.0es3.com.ar/*` | `https://0e3.com.ar/$1` | 301 |

> Firebase Hosting **no** hace redirect cross-domain nativo entre apex distintos. Usar Cloudflare.

---

## Landing — `0e3.com.ar`

### Registros típicos (valores exactos desde Firebase Console)

| Tipo | Nombre | Valor | Notas |
|---|---|---|---|
| TXT | `@` o `_firebase...` | (desde Firebase) | Verificación dominio |
| A | `@` | (desde Firebase) | Apex |
| CNAME | `www` | (desde Firebase o redirect) | Opcional |

### Proxy Cloudflare

| Fase | Configuración |
|---|---|
| Verificación inicial | **DNS only** (gris) en registros Firebase |
| Post-SSL | Evaluar proxy naranja según compatibilidad |

---

## Verificación

```powershell
Invoke-WebRequest -Uri "https://0e3.com.ar" -UseBasicParsing
Invoke-WebRequest -Uri "https://0es3.com.ar" -MaximumRedirection 0
# Debe ser 301 hacia 0e3.com.ar
```

Checklist:

- [x] `https://0e3.com.ar` → 200, certificado válido
- [x] `https://0es3.com.ar` → 301 → `0e3.com.ar`
- [ ] Subdominios producto (pendiente Fase 4+)

---

## Rollback DNS

1. Quitar custom domain en Firebase Console (site sigue en `.web.app`)
2. Desactivar redirect rules Cloudflare
3. Landing sigue en `https://0es3-com-ar.web.app`
