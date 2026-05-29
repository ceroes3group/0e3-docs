# Portal — Sección Productos (especificación hub)

**Portal objetivo:** `https://0es3.com.ar`  
**Implementación actual (transición):** `0e3-landing` → `https://0e3.com.ar`  
**Repo objetivo portal:** `ceroes3group/0e3-home`

---

## Sección Productos

Cada tarjeta debe incluir:

| Campo | Descripción |
|---|---|
| **Nombre** | Nombre comercial |
| **Descripción corta** | 1–2 líneas |
| **Estado** | `Disponible` \| `En desarrollo` \| `Próximamente` |
| **Enlace** | Ficha interna `/apps/{slug}/` o URL live |

---

## Catálogo objetivo

| Producto | Descripción corta | Estado | Enlace objetivo | URL live hoy |
|---|---|---|---|---|
| **Aliados Comerciales** | Red comercial y captación de aliados con wizard + IA | En desarrollo | `aliados.0es3.com.ar` | `oe3-aliados-comerciales.web.app` |
| **0E3 Gastro** | POS gastronómico — mesas, cocina, Android + web | En desarrollo | `gastro.0es3.com.ar` | `e3-gastro-staging-web.web.app` |
| **NexoPOS / 0E3 POS** | Punto de venta multi-tenant para comercios | Disponible | `nexopos.0es3.com.ar` | `nexopos-dc.web.app` |
| **Apps 0E3** | Catálogo de aplicaciones del ecosistema | Próximamente | `apps.0es3.com.ar` | — |
| **0E3 HOME** *(app finanzas)* | Gestión personal/familiar — beta separada del portal | En desarrollo | app dedicada | `oe3-home-beta.web.app` |

> **Nota:** la app Flutter “0E3 HOME” (finanzas) no es el portal corporativo. En el hub se lista como producto beta con enlace externo.

---

## Implementación existente (landing)

Fuente de verdad UI hoy: `0e3-landing` → `src/lib/constants.ts` (`appPages`, `liveUrls`)

Rutas:
- `/apps/` — catálogo
- `/apps/nexopos/`, `/apps/gastro/`, `/apps/aliados/`, `/apps/home/`

**Migración:** al consolidar portal en `0e3-home`, portar `constants.ts` y componentes de catálogo sin cambiar lógica de negocio.

---

## Secciones adicionales del hub

| Sección | Contenido |
|---|---|
| Hero | Marca 0E3 · Cero Es Tres |
| Productos | Tabla anterior |
| Demos | Links directos a `.web.app` staging |
| Aliados | CTA “Quiero ser aliado” → wizard |
| Contacto | `ceroes3group@gmail.com` |
| Docs | GitHub `0e3-docs` / futuro `docs.0es3.com.ar` |

---

## Qué NO incluir en el portal

- Checkout / MercadoPago
- Auth de productos
- Firestore / APIs producto
- Lógica wizard Aliados (solo link)
