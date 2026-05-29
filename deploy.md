# Deploy — Ecosistema 0E3

**Principio:** cada producto despliega desde **su propio repo** y **su propio proyecto Firebase**.

---

## Matriz de deploy

| Producto | Comando / pipeline | Target | Dominio objetivo |
|---|---|---|---|
| **Portal / Landing** | `npm run deploy:hosting` | `oe3-institutional` / `0es3-com-ar` | `0es3.com.ar` |
| **Aliados** | `firebase deploy` (root) | `oe3-aliados-comerciales` | `aliados.0es3.com.ar` |
| **Gastro web stg** | `scripts/deploy-staging-web.ps1` | `e3-gastro-staging-web` | `staging.gastro.0es3.com.ar` |
| **Gastro APK/OTA** | `scripts/deploy-android-hosting.ps1` | `e3-gastro-staging` | `staging.0es3.com.ar` |
| **Gastro Functions** | `firebase deploy --only functions` | `e3-gastro-staging` | — |
| **HOME app** | Flutter build + Firebase Hosting | `oe3-home-beta` | TBD (app ≠ portal) |
| **POS** | Cloud Run / Firebase (repo externo) | `nexopos-dc` | `nexopos.0es3.com.ar` |
| **Docs** | GitHub (futuro: static hosting) | — | `docs.0es3.com.ar` |

---

## Portal (Next.js estático)

```powershell
cd C:\Users\Asus\Proyectos\0E3_WORKSPACE\landing
npm run build:firebase
npm run deploy:hosting
```

Guía: repo `0e3-landing` → `docs/DEPLOY-FIREBASE.md`

---

## Aliados (monorepo)

```powershell
cd C:\Users\Asus\Proyectos\0E3_WORKSPACE\aliados-comerciales
npm install
npm run build --workspaces
firebase deploy --project oe3-aliados-comerciales
```

Desplegar **Hosting + Functions + Rules** por separado si se requiere ventana de mantenimiento.

---

## Gastro

| Artefacto | Script | Site |
|---|---|---|
| Web PWA staging | `deploy-staging-web.ps1` | `e3-gastro-staging-web` |
| APK + OTA | `deploy-android-hosting.ps1` | `e3-gastro-staging` |
| Functions | `firebase deploy --only functions --project e3-gastro-staging` | — |

> **No redeploy** APK/OTA site sin aprobación — tablets en producción staging.

CI workflow local (no en GitHub aún): `.github/workflows/deploy-android-hosting.yml`

---

## Entornos

| Entorno | Uso | Credenciales |
|---|---|---|
| **Local** | Dev | `.env.local`, emulators |
| **Staging** | QA, MP test | Secrets staging |
| **Production** | Clientes reales | Secrets prod — ventana planificada |

---

## Checklist pre-deploy

- [ ] Branch correcta (`main` / `release/*`)
- [ ] Tests / lint CI verdes
- [ ] Sin secretos en diff
- [ ] Variables env en Secret Manager actualizadas
- [ ] DNS/custom domain verificado post-deploy
- [ ] Rollback documentado

---

## Referencias

- Mapa hosting: [`firebase/oe3-hosting-map.md`](firebase/oe3-hosting-map.md)
- Landing deploy: [`deployments/landing-firebase-deploy.md`](deployments/landing-firebase-deploy.md)
- CI/CD estándar: [`support-core/ci-cd-standard.md`](support-core/ci-cd-standard.md)
