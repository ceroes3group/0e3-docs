# Deploy Landing — Firebase Hosting

**Producto:** 0E3 Landing institucional  
**Repo:** https://github.com/ceroes3group/0e3-landing  
**Hash referencia:** `dadfe700550add143bd91ca6934249ce4e80dfbe`  
**Actualizado:** 2026-05-27

Guía operativa completa en el repo del producto:  
https://github.com/ceroes3group/0e3-landing/blob/main/docs/DEPLOY-FIREBASE.md

---

## Resumen técnico

| Item | Valor |
|---|---|
| Framework | Next.js 16 (App Router) + React 19 + TypeScript |
| Build | `npm run build:firebase` → carpeta `out/` |
| Proyecto Firebase | `oe3-institutional` |
| Hosting site ID | `0es3-com-ar` (**no renombrar**) |
| Dominio canónico | `https://0e3.com.ar` |
| URL Firebase default | https://0es3-com-ar.web.app |
| Alias redirect | `0es3.com.ar` → `0e3.com.ar` (Cloudflare) |

---

## Historial de deploys relevantes

| Fecha | Acción | Resultado |
|---|---|---|
| 2026-05-28 | Deploy inicial Fase 1 | ✅ Live en `0es3-com-ar.web.app` |
| 2026-05-28 | Custom domain `0e3.com.ar` | ✅ SSL activo |
| 2026-05-28 | Merge `chore/oe3-domains-architecture` → `main` | Build OK, sin redeploy |
| 2026-05-27 | Push GitHub `main` | ✅ `dadfe70` publicado |
| 2026-05-27 | Redirect `0es3.com.ar` | ✅ Cloudflare manual |

---

## Comandos (referencia)

```powershell
cd C:\Users\Asus\Proyectos\0E3_WORKSPACE\landing
npm install
npm run build:firebase
npm run deploy:hosting
```

---

## Rutas publicadas

- `/` — landing institucional
- `/apps/` — catálogo de productos
- `/apps/nexopos/`, `/apps/gastro/`, `/apps/aliados/`, `/apps/home/` — fichas

---

## Relación con otros sistemas

Ver [`../firebase/oe3-hosting-map.md`](../firebase/oe3-hosting-map.md)
