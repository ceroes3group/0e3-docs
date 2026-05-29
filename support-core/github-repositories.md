# Repositorios 0E3

## Coordinacion activa

Ver detalle completo en [coordinacion-repos.md](coordinacion-repos.md).

- **0E3 POS** = `nexopos-dc-multi-tenant` (conceptual, productivo, sin migrar todavia).
- **Cuenta madre objetivo:** `ceroes3group`.
- **Repos a preparar ahora:** `0e3-brand`, `0e3-docs`, `0e3-landing`, `0e3-pos-web`.
- **Repo diferido:** `0e3-pos` (solo cuando el roadmap 0E3 POS este estable).

## Repositorios publicos — preparar ahora

- `0e3-landing`: landing institucional y sitio publico.
- `0e3-brand`: identidad visual, guias de marca y assets publicables.
- `0e3-docs`: documentacion publica, manuales comerciales y guias.

## Repositorios privados — preparar ahora

- `0e3-pos-web`: placeholder para futura capa web/admin de 0E3 POS.

## Repositorios privados — diferidos

- `0e3-pos`: destino final del producto POS. **No crear ni migrar todavia.**
- `0e3-gastro`: producto gastronomico.
- `0e3-ai`: automatizaciones, asistentes e integraciones IA.
- `0e3-cloud`: infraestructura, servicios compartidos y operaciones cloud.
- `0e3-track`: tracking operativo, auditoria o trazabilidad.
- `0e3-recovery`: recuperacion, backup y continuidad.
- `0e3-forense`: herramientas forenses y analisis tecnico.
- `brand-launcher`: generador interno de assets y material de lanzamiento.

## Comandos GitHub CLI — fase de preparacion

Ejecutar solo cuando `gh` este autenticado con `ceroes3group`:

```powershell
cd C:\Users\Asus\Proyectos\0E3_WORKSPACE
.\scripts\create-github-repos-prepare.ps1
```

Equivalente manual:

```powershell
gh repo create ceroes3group/0e3-landing --public
gh repo create ceroes3group/0e3-brand --public
gh repo create ceroes3group/0e3-docs --public
gh repo create ceroes3group/0e3-pos-web --private
```

## Comandos diferidos — no ejecutar todavia

```powershell
# gh repo create ceroes3group/0e3-pos --private
# gh repo create ceroes3group/0e3-gastro --private
# ... otros productos
```

## Autenticacion

```powershell
gh auth login
gh auth status
```

Si se necesita scope de organizacion:

```powershell
gh auth refresh -h github.com -s admin:org
```

## Checklist para subir repos de preparacion

- Confirmar sesion `gh` con cuenta `ceroes3group`.
- Crear solo repos de la fase de preparacion.
- Revisar `.gitignore` antes del primer commit.
- Verificar que no existan secretos ni credenciales.
- Subir README base desde `repo-templates/`.
- No tocar remotes del repo productivo NexoPOS.

## Checklist antes de migrar 0E3 POS

- Roadmap 0E3 POS estable y acordado.
- Auditoria de secretos completada.
- Plan de rollback documentado.
- Ventana de mantenimiento definida si hay clientes activos.
- Decision tomada entre `0e3-pos` vs `0e3-pos-web` como destino.
