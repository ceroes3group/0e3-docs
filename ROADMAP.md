# Roadmap 0E3

## Fase 1: Branding 0E3

- Definir logo, paleta, tipografia y tono institucional.
- Crear guia de marca inicial.
- Preparar assets para GitHub, web y redes.
- Crear repos vacios: `0e3-brand`, `0e3-docs`, `0e3-landing`.

## Fase 2: 0E3 POS — estabilizacion (sin migracion)

**Coordinacion:** el repo/app actual `nexopos-dc-multi-tenant` se trata como **0E3 POS** a nivel conceptual. **No mover ni renombrar** el repo productivo en esta fase.

- Auditar repositorio productivo actual.
- Limpiar secretos y configuraciones locales.
- Documentar stack, instalacion y comandos.
- Reservar `0e3-pos-web` como placeholder para futura capa web/admin.
- Completar roadmap tecnico y comercial de 0E3 POS.
- Definir criterios de migracion y rollback.

### Criterio de salida de Fase 2

Solo cuando el roadmap 0E3 POS este estable se habilita la Fase 2b (migracion).

## Fase 2b: Migracion 0E3 POS (diferida)

- Crear o usar repo destino (`0e3-pos` o `0e3-pos-web` segun decision final).
- Transferir codigo con historial auditado.
- Actualizar remotes, CI/CD y documentacion.
- Archivar repo legacy.

## Fase 3: Migracion 0E3 Gastro

- Auditar repositorio actual (`nexopos_gastro_pos`).
- Separar configuracion sensible.
- Migrar codigo a `0e3-gastro`.
- Definir relacion tecnica con 0E3 POS.

## Fase 4: Landing oficial

- Crear landing institucional en `0e3-landing`.
- Publicar propuesta de valor, productos y contacto.
- Preparar SEO basico.

## Fase 5: Dominio pos.0e3.com.ar

- Definir hosting o plataforma.
- Configurar DNS.
- Validar HTTPS.

## Fase 6: Cloudflare + correo corporativo

- Configurar DNS centralizado.
- Evaluar correo corporativo.
- Configurar politicas SPF, DKIM y DMARC.

## Fase 7: Documentacion comercial

- Crear documentacion para ventas, onboarding y soporte en `0e3-docs`.
- Preparar FAQs y material por producto.
- Definir proceso de mantenimiento documental.
