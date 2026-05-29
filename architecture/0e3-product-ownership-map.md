# Mapa de ownership — Productos 0E3

**Versión:** 1.0  
**Fecha:** 2026-05-27  
**Alcance:** naming, repos, dominios — sin cambios en código

---

## Tabla maestra

| Producto | Descripción | Repo actual | Repo recomendado | Dominio actual | Dominio objetivo | Estado |
|---|---|---|---|---|---|---|
| **Portal institucional** | Hub marca, productos, demos, contacto — sin lógica negocio | `ceroes3group/0e3-landing` | `0e3-landing` ✅ | `0e3.com.ar` | `0es3.com.ar` | 🟡 Live en apex legacy |
| **0E3 POS / NexoPOS** | POS multi-tenant web + Android | `danielcadiz15/nexopos-dc-multi-tenant` | `ceroes3group/0e3-pos` | `nexopos-dc.web.app` | `pos.0es3.com.ar` | 🟢 Prod activo |
| **0E3 Gastro** | POS gastronómico Flutter + Functions | `ceroes3group/0e3-gastro` | `0e3-gastro` ✅ | `e3-gastro-staging-web.web.app` | `gastro.0es3.com.ar` | 🟡 Staging |
| **0E3 Home (app finanzas)** | App Flutter personal/familiar beta | `ceroes3group/0e3-home` ⚠️ | `0e3-home-app` | `oe3-home-beta.web.app` | `home.0es3.com.ar` | 🟡 Conflicto naming |
| **Aliados Comerciales** | Captación aliados, wizard, IA, panel | `ceroes3group/0e3-aliados-comerciales` | `0e3-aliados-comerciales` ✅ | `oe3-aliados-comerciales.web.app` | `aliados.0es3.com.ar` | 🟡 GitHub OK, WIP local |
| **0E3 Docs** | Documentación transversal | `ceroes3group/0e3-docs` | `0e3-docs` ✅ | GitHub | `docs.0es3.com.ar` | 🟢 Publicado |
| **Billing Core** (futuro) | Abonos SaaS transversal MP | — | `0e3-billing` | — | `billing.0es3.com.ar` | ⏸ Diseño |
| **Support Core** (futuro) | Tickets, diagnóstico, logging | — | `0e3-support` | — | `support.0es3.com.ar` | ⏸ Diseño |

---

## Conflictos de naming detectados

### 🔴 Crítico: `0e3-home`

| Expectativa | Realidad |
|---|---|
| Portal corporativo / hub (`0es3.com.ar`) | Repo contiene **app Flutter finanzas** (`oe3_home`) |
| Nombre sugiere “sitio home” institucional | Producto es **0E3 HOME** — gestión personal |

**Impacto:**

| Audiencia | Confusión |
|---|---|
| **Desarrolladores** | Clone `0e3-home` esperando Next.js portal; encuentra Flutter |
| **Deploy** | Firebase `oe3-home-beta` mezclado mentalmente con portal `0es3-com-ar` |
| **Clientes** | “Home” puede significar portal web o app finanzas |

**Resolución recomendada:** renombrar repo app → `0e3-home-app`; reservar naming portal para `0e3-landing` hasta migración apex.

---

### 🟡 Medio: apex `0e3.com.ar` vs `0es3.com.ar`

| Hoy | Objetivo estratégico |
|---|---|
| `0e3.com.ar` = landing canónica | `0es3.com.ar` = portal canónico |
| `0es3.com.ar` → redirect a `0e3.com.ar` | Invertir o reemplazar redirect |

**Impacto clientes:** bookmarks y SEO en transición.  
**Impacto devs:** `constants.ts`, metadata, MP back_urls referencian ambos.

---

### 🟡 Medio: POS fuera de org `ceroes3group`

| Hoy | Objetivo |
|---|---|
| `danielcadiz15/nexopos-dc-multi-tenant` | `ceroes3group/0e3-pos` |

**Impacto:** permisos, CI, visibilidad ecosistema fragmentados.

---

### 🟡 Medio: Gastro historial Git divergente

| Local | Remoto |
|---|---|
| `chore/oe3-architecture` @ `01e14d8` (+ workflow, zip cleanup) | `chore/oe3-architecture` @ `8f57c9a` (squash + doc) |

**Impacto devs:** push/pull no trivial; workflow CI solo local.

---

### 🟢 Bajo: Firebase site ID `0es3-com-ar`

Site ID histórico no coincide con apex objetivo `0es3.com.ar`. **No renombrar** — solo documentar.

---

## Matriz repo ↔ dominio ↔ Firebase

| Repo recomendado | Dominio objetivo | Firebase project | Site ID |
|---|---|---|---|
| `0e3-landing` | `0es3.com.ar` | `oe3-institutional` | `0es3-com-ar` |
| `0e3-pos` | `pos.0es3.com.ar` | `nexopos-dc` | `nexopos-dc` |
| `0e3-gastro` | `gastro.0es3.com.ar` | `e3-gastro` / staging | `e3-gastro-staging-web`, etc. |
| `0e3-home-app` | `home.0es3.com.ar` | `oe3-home-beta` | default |
| `0e3-aliados-comerciales` | `aliados.0es3.com.ar` | `oe3-aliados-comerciales` | default |
| `0e3-docs` | `docs.0es3.com.ar` | TBD | TBD |
| `0e3-billing` | `billing.0es3.com.ar` | TBD dedicado | TBD |
| `0e3-support` | `support.0es3.com.ar` | TBD dedicado | TBD |

**Regla:** 1 repo = 1 producto deployable = 1 dominio primario (staging aparte).

---

## Glosario naming oficial (propuesto)

| Término | Significado |
|---|---|
| **0E3** | Marca / organización |
| **Portal** | Sitio institucional hub (`0es3.com.ar`) |
| **0E3 HOME** | App finanzas personales (Flutter) |
| **0E3 POS** | NexoPOS multi-tenant |
| **0E3 Gastro** | POS gastronómico |
| **Aliados Comerciales** | Red comercial / captación |
| **Billing Core** | Motor transversal de suscripciones |
| **Support Core** | Motor transversal de soporte |

---

## Referencias

- Estructura final: [`0e3-final-ecosystem-structure.md`](0e3-final-ecosystem-structure.md)
- Informe Fase N: [`../reports/FASE-N-ESTRATEGICA-REPORTE.md`](../reports/FASE-N-ESTRATEGICA-REPORTE.md)
