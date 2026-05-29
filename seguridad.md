# Seguridad — Ecosistema 0E3

**Principio:** secretos fuera de Git; acceso mínimo; revisión antes de cada push.

---

## Clasificación de secretos

| Tipo | Ejemplos | Dónde vive |
|---|---|---|
| **Firebase** | Service accounts, `google-services.json` | Secret Manager / local gitignored |
| **MercadoPago** | `MERCADOPAGO_ACCESS_TOKEN`, `MP_ACCESS_TOKEN` | Firebase Secrets / `.env` gitignored |
| **Meta / WhatsApp** | `WHATSAPP_ACCESS_TOKEN`, verify token | Firebase Secrets |
| **OpenAI** | `OPENAI_API_KEY` | Firebase Secrets |
| **CI** | `FIREBASE_TOKEN`, deploy keys | GitHub Secrets |
| **Android** | Keystores, `key.properties` | Local seguro, nunca Git |

---

## `.gitignore` obligatorio por repo

Todo repo debe ignorar como mínimo:

```
.env
.env.*
!.env.example
**/google-services.json
*-service-account*.json
*.pem
*.key
*.keystore
*.jks
key.properties
functions/.env*
.staging-bypass.credentials.local
*.zip
```

---

## Checklist automático

Ejecutar desde la raíz de cada repo antes de push:

```powershell
# 1) Archivos sensibles trackeados
git ls-files | Select-String -Pattern '\.env$|google-services\.json|serviceAccount|\.pem$|\.key$|sk_live|sk_test|APP_USR-|TEST-[a-f0-9]{32}'

# 2) Secretos en diff staged
git diff --cached | Select-String -Pattern 'APP_USR-|sk_live|sk_test|BEGIN (RSA )?PRIVATE KEY|WHATSAPP_ACCESS_TOKEN\s*=\s*[^$]'

# 3) Historial reciente (opcional)
git log -5 --oneline
```

Script reutilizable: [`scripts/security-audit.ps1`](scripts/security-audit.ps1)

**Resultado esperado:** cero coincidencias en pasos 1–2.

---

## Por producto — estado auditado (2026-05-27)

| Repo | `.env` en Git | Tokens MP | Meta/OpenAI | Notas |
|---|---|---|---|---|
| `0e3-landing` | ✅ No | N/A | N/A | Estático, sin backend |
| `0e3-aliados` | ✅ No (`.env.example` sí) | N/A | Secrets en Functions | WIP local sin push |
| `0e3-home` (Flutter) | ✅ No | N/A | N/A | `google-services.json` ignorado |
| `0e3-gastro` | ✅ No | Solo docs/ejemplos | N/A | `firebase_options.dart` = keys client públicas |
| `0e3-docs` | ✅ No | Solo referencias | N/A | Solo markdown |
| `nexopos-dc` | Verificar repo externo | Secret `MERCADOPAGO_ACCESS_TOKEN` | N/A | Producción activa |

---

## Firebase

- Rules: revisión en PR para cambios en `firestore.rules`
- App Check: habilitar en staging antes de prod (Gastro: `APP_CHECK_SETUP.md`)
- Separación proyectos: no compartir service accounts entre prod/staging

---

## GitHub

- Repos **privados** por defecto
- Branch protection en `main`: require PR, status checks
- Secrets en **Settings → Secrets and variables → Actions**
- Scope `workflow` requerido para push de `.github/workflows/`

---

## MercadoPago

- Access token **solo backend**
- Webhook URL registrada en panel MP = URL real desplegada
- No cambiar `MP_BACK_URL` sin prueba end-to-end staging

Ver: [`billing/mercadopago-integration-plan.md`](billing/mercadopago-integration-plan.md)

---

## Respuesta a incidentes

1. Rotar secret comprometido en proveedor
2. `firebase functions:secrets:set` nueva versión
3. Redeploy Functions afectadas
4. Auditar `git log` / GitHub history — `git filter-repo` solo con plan

---

## Referencias

- Checklist script: [`scripts/security-audit.ps1`](scripts/security-audit.ps1)
- Aliados setup: repo `0e3-aliados-comerciales` → `docs/FIREBASE_SETUP.md`
