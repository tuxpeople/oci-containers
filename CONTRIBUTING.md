# Contributing to OCI Containers

Danke für dein Interesse! Hier sind die Guidelines.

## 🎯 Quick Start

1. **Fork & Clone**
2. **Erstelle ein neues Image** unter `images/my-app`
3. **Teste lokal:** Hadolint, Build, Trivy
4. **Commit & Push** mit Conventional Commits

## 📝 Commit Messages

**WICHTIG:** Commit Messages steuern automatisches Versioning!

Verwende [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types und Versioning

| Type | Beschreibung | Version Bump |
|------|--------------|-------------|
| `fix` | Bug Fix | **Patch** (1.0.0 → 1.0.1) |
| `feat` | Neues Feature | **Minor** (1.0.0 → 1.1.0) |
| `feat!` | Breaking Change | **Major** (1.0.0 → 2.0.0) |
| `docs` | Nur Dokumentation | Kein Bump |
| `chore` | Wartung/Dependencies | **Patch** |
| `refactor` | Code Refactoring | Kein Bump |
| `test` | Tests | Kein Bump |
| `ci` | CI/CD Änderungen | Kein Bump |

### Breaking Changes

Für Major Version Bump:

```bash
# Option 1: ! nach Type
git commit -m "feat(my-app)!: change API schema"

# Option 2: BREAKING CHANGE im Footer
git commit -m "feat(my-app): change API schema

BREAKING CHANGE: /v1 endpoint removed, use /v2"
```

### Beispiele

```bash
# Neues Feature (→ Minor bump)
git commit -m "feat(nginx): add custom error pages"

# Bug Fix (→ Patch bump)
git commit -m "fix(postgres): correct healthcheck script"

# Dependency Update (→ Patch bump)
git commit -m "chore(alpine-base): update to alpine 3.20"

# Breaking Change (→ Major bump)
git commit -m "feat(api)!: change authentication method

BREAKING CHANGE: OAuth2 now required, API keys removed"

# Dokumentation (kein Bump)
git commit -m "docs(readme): update installation instructions"

# Mehrere Images
git commit -m "feat(nginx,postgres): add init scripts"
```

### Erste Version

Erster Commit für ein neues Image erstellt automatisch `v0.1.0`:

```bash
git commit -m "feat(my-app): add new container image"
# → Erstellt my-app-v0.1.0
```

## 🏗️ Image Struktur

**MUSS haben:**
```
images/my-app/
├── Dockerfile       # REQUIRED
├── README.md        # REQUIRED
└── goss.yaml        # REQUIRED
```

**KANN haben:**
```
images/my-app/
├── .trivyignore     # Optional: Ignore specific CVEs
└── test.sh          # Optional: Custom tests
```

## ✅ Dockerfile Requirements

### MUSS

```dockerfile
# 1. Spezifische Tags
FROM alpine:3.19  # ✅ GOOD

# 2. OCI Labels
LABEL org.opencontainers.image.title="my-app"
LABEL org.opencontainers.image.description="My application"

# 3. Non-root user
USER 1000

# 4. Health Check (wenn App einen Port exposed)
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8080/ || exit 1
```

## 🧪 Testing

### Hadolint (Pflicht)
```bash
hadolint images/my-app/Dockerfile
```

### Trivy (Pflicht)
```bash
trivy image my-app:test
# CRITICAL & HIGH müssen gefixt werden
```

### Goss (PFLICHT für alle Images)

**Jedes Image MUSS `goss.yaml` haben!**

```bash
GOSS_FILE=images/my-app/goss.yaml dgoss run my-app:test
```

**Minimum goss.yaml:**
```yaml
package:
  bash:
    installed: true
    
command:
  bash --version:
    exit-status: 0
```

**Wichtig:** Container CMD muss laufen:
```dockerfile
CMD ["sleep", "infinity"]  # NICHT CMD ["/bin/bash"]!
```

## 🔐 Security Guidelines

### ❌ NIE
- Secrets im Dockerfile
- Root user für Runtime
- `latest` Tags für Base Images

### ✅ IMMER
- Minimal Base Images (alpine, distroless)
- Security Updates zeitnah einspielen
- Non-root user

## 📋 Pull Request Checklist

- [ ] Dockerfile folgt Best Practices
- [ ] Hadolint passed
- [ ] Trivy hat keine CRITICAL/HIGH CVEs
- [ ] **goss.yaml existiert und Tests passen**
- [ ] README.md existiert
- [ ] Lokal gebaut und getestet
- [ ] Commit Messages folgen Conventional Commits

## 🙏 Danke!

Dein Beitrag macht dieses Projekt besser! 🎉
