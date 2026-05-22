# Coordinacion de repositorios 0E3

## Cuenta madre

- Cuenta institucional objetivo: `ceroes3group`
- Cuentas origen con repos existentes: `condinea1234`, `danielcadiz15`
- Objetivo final: unificar bajo `ceroes3group`
- Regla actual: **no mover ni renombrar repos productivos hasta que el roadmap 0E3 POS este estable**

## Mapeo producto actual → 0E3

| Producto 0E3 | Repo / app actual | Estado |
|---|---|---|
| **0E3 POS** | `nexopos-dc-multi-tenant` (+ `nexopos-dc-caja-android` como cliente caja) | Productivo. Tratar como 0E3 POS a nivel conceptual. **Sin migracion todavia.** |
| 0E3 Gastro | `nexopos_gastro_pos` | Fuera de alcance inmediato |
| 0E3 Brand | assets locales en `0E3_WORKSPACE/brand/` | Preparacion |
| 0E3 Docs | documentacion futura | Preparacion |
| 0E3 Landing | landing futura | Preparacion |
| 0E3 POS Web | reservado para capa web/admin del POS | Preparacion de repo vacio |

## Repos a preparar ahora

Estos repos pueden crearse vacios en `ceroes3group` para reservar nombre, README base y estructura:

| Repo | Visibilidad sugerida | Proposito |
|---|---|---|
| `0e3-brand` | publico | Identidad visual, guias y assets publicables |
| `0e3-docs` | publico | Documentacion institucional y comercial |
| `0e3-landing` | publico | Sitio institucional |
| `0e3-pos-web` | privado | Placeholder para futura capa web/admin de 0E3 POS |

## Repos diferidos (no tocar todavia)

| Repo | Motivo |
|---|---|
| `0e3-pos` | El producto productivo sigue en su repo actual (`nexopos-dc-multi-tenant`). Migrar solo cuando el roadmap 0E3 POS este estable. |
| `0e3-gastro`, `0e3-ai`, `0e3-cloud`, etc. | Fuera de la fase actual de coordinacion |

## Que NO hacer en esta fase

- No renombrar `nexopos-dc-multi-tenant` a `0e3-pos`.
- No transferir el repo productivo a `ceroes3group` sin plan de rollback.
- No cambiar remotes locales de proyectos en produccion.
- No publicar secretos, `.env`, keystores ni service accounts durante la preparacion.
- No activar deploy automatico en repos nuevos.

## Criterio para habilitar migracion 0E3 POS

La migracion del repo productivo puede evaluarse cuando se cumplan:

1. Roadmap 0E3 POS estable y acordado.
2. Auditoria de secretos completada.
3. `.gitignore`, `SECURITY.md` y `.env.example` validados.
4. Plan de rollback documentado.
5. Ventana de mantenimiento acordada si hay clientes activos.
6. Cuenta `ceroes3group` autenticada en `gh` con permisos suficientes.

## Flujo recomendado de unificacion

### Fase A — Preparacion (ahora)

1. Autenticar `gh` con `ceroes3group`.
2. Crear repos vacios: `0e3-brand`, `0e3-docs`, `0e3-landing`, `0e3-pos-web`.
3. Subir README base, politicas y workflows desde `0E3_WORKSPACE`.
4. Mantener NexoPOS operando en su repo actual.

### Fase B — Estabilizacion 0E3 POS

1. Completar roadmap tecnico y comercial de 0E3 POS.
2. Definir si `0e3-pos-web` absorbe solo web/admin o todo el stack.
3. Auditar historial git y secretos del repo productivo.

### Fase C — Migracion controlada

1. Crear `0e3-pos` o usar `0e3-pos-web` segun decision final.
2. Transferir o replicar codigo con historial limpio.
3. Actualizar remotes locales y CI/CD.
4. Archivar repos legacy en cuentas origen.
