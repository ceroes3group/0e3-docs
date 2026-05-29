# Support Core — Análisis de brechas (gap analysis)

**Versión:** 1.0  
**Fecha:** 2026-05-27  
**Estado:** Preparación — **sin implementación**

---

## 1. Qué puede compartirse entre productos

| Capacidad | POS | Gastro | HOME | Aliados | Compartible |
|---|---|:---:|:---:|:---:|:---:|:---:|
| **Logging estructurado** | Parcial (Functions) | ✅ adminLogs | Limitado | interpretation_logs | ✅ |
| **Health check endpoint** | ✅ API | ✅ Functions | ❌ | ✅ health | ✅ |
| **Diagnóstico cliente** | Parcial | ✅ system_health | ❌ | ❌ | ✅ |
| **Panel admin plataforma** | ✅ super admin | ✅ platformAdmins | ❌ | ✅ panel | ✅ |
| **Tickets soporte** | ❌ | ❌ | ❌ | ❌ | 🆕 Core |
| **FAQ / knowledge base** | Docs repo | Docs in-app | FAQ doc | knowledgeBase IA | ✅ parcial |
| **Reporte errores** | ❌ | CURRENT_ISSUES | ❌ | ❌ | 🆕 Core |
| **Session/device info** | ✅ sesiones | ✅ devices | Auth | ❌ | ✅ |
| **Audit trail** | Parcial | ✅ adminLogs | ❌ | ❌ | ✅ |

---

## 2. Dependencias comunes existentes

| Dependencia | Dónde aparece |
|---|---|
| **Firebase Auth** | Todos los productos |
| **Firestore** | Todos |
| **Firebase Functions** | POS, Gastro, Aliados |
| **Firebase Hosting** | Portal, Aliados, Gastro, HOME web |
| **Cloudflare DNS** | Ecosistema dominios |
| **GitHub Actions** | Templates workspace (parcial) |
| **MercadoPago** | POS, Gastro (soporte billing-related) |
| **OpenAI** | Aliados (no Support Core directo) |
| **WhatsApp Meta** | Aliados canal soporte paralelo |

---

## 3. Stack común recomendado (Support Core)

| Capa | Tecnología | Justificación |
|---|---|---|
| **Datos** | Firestore (`0e3-support` project) | Consistente con ecosistema |
| **Backend** | Firebase Functions Gen2 (TypeScript) | Mismo patrón Gastro/POS moderno |
| **Auth** | Firebase Auth + custom claims `supportAgent` | SSO agents 0E3 |
| **Logging** | Cloud Logging + `supportEvents` Firestore | Trazabilidad cross-product |
| **Diagnostics** | Callable `collectDiagnosticBundle` | App Flutter/React envía snapshot |
| **Tickets** | Firestore `supportTickets` + estados | CRM mínimo |
| **Notificaciones** | Email / webhook Slack (futuro) | Escalación |
| **UI agentes** | React admin (`0e3-support` repo) | Panel centralizado |
| **UI cliente** | Widget embebible por producto | Botón “Ayuda” → ticket |

### Dominio objetivo

`https://support.0es3.com.ar` — portal agentes + status page pública.

---

## 4. Módulos empaquetables

| Módulo | Formato | Consumidores |
|---|---|---|
| **@0e3/support-client** | npm package React | POS web, Aliados web, portal |
| **0e3_support** | Dart package Flutter | Gastro, HOME app |
| **support-core-functions** | Firebase Functions shared | Import en cada proyecto o central |
| **Diagnostic schema** | JSON Schema / TS types | Compartido npm + codegen Dart |

### Contenido `@0e3/support-client`

- `SupportWidget` — botón + modal ticket
- `useSupportTicket()` — hook
- `collectDiagnostics()` — browser info
- Tipos `SupportTicket`, `TicketStatus`

### Contenido `0e3_support` (Dart)

- `SupportFab` widget
- `DiagnosticReport.capture()`
- Integración con `package_info_plus`, connectivity

### Backend común (`0e3-support`)

| Callable / HTTP | Función |
|---|---|
| `createTicket` | Alta ticket desde cualquier producto |
| `listTickets` | Panel agente |
| `updateTicketStatus` | Workflow |
| `appendTicketMessage` | Chat async |
| `getSystemStatus` | Status page |

---

## 5. Qué NO centralizar (permanece en producto)

| Área | Motivo |
|---|---|
| WhatsApp Aliados | Canal producto-specific |
| IA supervisada Aliados | Dominio negocio |
| Gastro OTA / APK diagnostics | Crítico, acoplado deploy |
| POS billing support | Hasta Billing Core |
| Firestore rules producto | Seguridad por tenant |

---

## 6. Brechas actuales

| Brecha | Impacto | Prioridad |
|---|---|---|
| Sin ticket system unificado | Soporte fragmentado email/WhatsApp | 🔴 Alta |
| Sin status page | Clientes no ven incidentes | 🟡 Media |
| Logs no correlacionados cross-product | Debug lento | 🟡 Media |
| Sin diagnostic bundle estándar | Reproducción difícil | 🟡 Media |
| Gastro `system_health` no exportable | Duplicar en otros productos | 🟢 Baja |

---

## 7. Orden implementación sugerido (post-aprobación)

1. Repo `0e3-support` + schema Firestore tickets
2. Callable `createTicket` + panel React mínimo
3. Widget React en Aliados (bajo riesgo)
4. Package Flutter en Gastro staging
5. Integración POS (post-migración org)
6. HOME greenfield
7. Status page pública

---

## 8. Relación con Billing Core

| Escenario | Support Core |
|---|---|
| Suscripción vencida | Ticket auto-categoría `billing` |
| Pago rechazado MP | Link a Billing UI + ticket |
| Admin reactivación manual | Log en `supportEvents` |

Coordinar entitlements: Support **no** bloquea acceso — Billing sí.

---

## Referencias

- Arquitectura general: [`../arquitectura-general.md`](../arquitectura-general.md)
- CI/CD: [`ci-cd-standard.md`](ci-cd-standard.md)
- Gastro system health: repo `0e3-gastro` → `lib/features/system_health/`
