# CI/CD estándar — 0E3

**Objetivo:** workflows reutilizables por tipo de proyecto (web, Flutter, docs).

Plantillas en: [`../.github/workflows/`](../.github/workflows/) (workspace templates)

---

## Matriz CI por tipo

| Tipo | Jobs | Node / SDK |
|---|---|---|
| **Web (Next/React/Vite)** | lint → test → build | Node 20 → 22 (plan) |
| **Functions** | lint → test → build TS | Node 22 |
| **Flutter** | analyze → test → (build opcional) | Flutter stable |
| **Docs** | markdown link check, secret scan | Node 20 |

---

## Workflow web (plantilla)

Archivo: `.github/workflows/web-ci.yml`

```yaml
name: Web CI
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: npm
      - run: npm ci
      - run: npm run lint --if-present
      - run: npm test --if-present
      - run: npm run build
```

---

## Workflow Flutter (plantilla)

Archivo: `.github/workflows/flutter-ci.yml`

```yaml
name: Flutter CI
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

---

## Workflow deploy (manual / protected)

- **Solo** desde `main` o tag `v*`
- Requiere environment `production` con aprobación manual
- Secrets: `FIREBASE_TOKEN` o Workload Identity

Gastro APK deploy: `deploy-android-hosting.yml` — requiere scope `workflow` en `gh auth`.

---

## Repos — estado CI

| Repo | CI en GitHub | Deploy CI |
|---|---|---|
| `0e3-landing` | ⏸ Agregar `web-ci.yml` | Manual Firebase |
| `0e3-aliados` | ⏸ Agregar monorepo CI | Manual |
| `0e3-gastro` | ⏸ Workflow local, no remoto | Manual + workflow local |
| `0e3-docs` | ⏸ `docs-check.yml` template | N/A |
| `0e3-home` | ⏸ Flutter CI | Manual |

---

## Secrets GitHub requeridos

| Secret | Uso |
|---|---|
| `FIREBASE_TOKEN` | Deploy Hosting (CI) |
| `MERCADOPAGO_*` | **Nunca** — solo Firebase Secret Manager |

---

## Orden de adopción

1. `0e3-docs` — docs-check + security-audit script
2. `0e3-landing` — web-ci
3. `0e3-aliados` — web-ci + functions build
4. `0e3-gastro` — flutter-ci (+ deploy workflow tras scope)
5. `nexopos-dc` — post-migración org

---

## Referencias

- Templates workspace: `0E3_WORKSPACE/.github/workflows/`
- Deploy: [`../deploy.md`](../deploy.md)
- Seguridad: [`../seguridad.md`](../seguridad.md)
