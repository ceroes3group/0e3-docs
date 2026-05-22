# Organizacion GitHub 0E3

## Nombre preferido

1. `0E3`
2. `ceroes3`
3. `cero-es-tres`
4. `ceroes3group`
5. `0e3group`

## Disponibilidad aparente

Consulta realizada con GitHub CLI contra la API publica:

- `0E3`: ocupado o existente.
- `ceroes3`: no encontrado por API publica.
- `cero-es-tres`: no encontrado por API publica.
- `ceroes3group`: no encontrado por API publica.
- `0e3group`: no encontrado por API publica.

Nota: "no encontrado por API publica" no garantiza disponibilidad final. GitHub puede reservar nombres o solicitar validaciones manuales durante la creacion.

## Perfil institucional

- Nombre institucional: Cero Es Tres
- Lema: Tecnologia que simplifica
- Logo local: `assets/logos/0e3-logo.png`
- Website: https://0e3.com.ar
- Email: ceroes3group@gmail.com
- Ubicacion: Argentina

## Descripcion sugerida

0E3 · Tecnologia que simplifica. Software, automatizacion, IA y soluciones empresariales.

## Checklist manual

- Crear la organizacion desde GitHub.
- Elegir el nombre disponible segun prioridad.
- Cargar logo institucional desde `assets/logos/0e3-logo.png`.
- Configurar descripcion institucional.
- Configurar website `https://0e3.com.ar`.
- Configurar email `ceroes3group@gmail.com`.
- Configurar ubicacion `Argentina`.
- Activar 2FA en la cuenta raiz y administradores.
- Definir al menos dos owners si la organizacion va a operar en produccion.
- Revisar permisos base de miembros.
- Crear equipos por area: `owners`, `dev`, `product`, `ops`.
- Mantener repos privados por defecto hasta completar revision de secretos.

## Carga manual del logo en GitHub

1. Entrar a GitHub con la cuenta administradora.
2. Abrir la organizacion creada.
3. Ir a `Settings`.
4. Abrir `Profile`.
5. Subir `assets/logos/0e3-logo.png` como avatar/logo.
6. Guardar cambios.

Si GitHub solicita CAPTCHA, 2FA, validacion de email o permisos adicionales, completar esos pasos manualmente desde el navegador.

## GitHub CLI

Estado verificado localmente:

- `gh` instalado.
- Sesion autenticada en GitHub.
- Para crear repositorios dentro de una organizacion puede requerirse scope `admin:org`.

Si se necesita autenticar de nuevo:

```powershell
gh auth login
gh auth status
```

Si se necesita ampliar permisos para operar organizaciones:

```powershell
gh auth refresh -h github.com -s admin:org
gh auth status
```

No crear organizaciones, repositorios ni cambios remotos sin confirmacion humana previa.
