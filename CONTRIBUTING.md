# Contributing to OCI Containers

Danke für dein Interesse! Hier sind die Guidelines.

## 🎯 Quick Start

1. **Fork & Clone**
2. **Erstelle ein neues Image** unter `images/my-app`
3. **Teste lokal:** Hadolint, Build, Trivy
4. **Commit & Push** mit Conventional Commits

## 📝 Commit Messages

Verwende [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(image-name): add feature
fix(image-name): fix bug
docs(image-name): update documentation
chore(image-name): update dependencies
```

## 🏗️ Image Struktur

**MUSS haben:**
```
images/my-app/
├── Dockerfile       # REQUIRED
└── README.md        # REQUIRED
```

**KANN haben:**
```
images/my-app/
├── goss.yaml        # Optional: Runtime tests
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

### Goss (Optional)
```bash
GOSS_FILE=images/my-app/goss.yaml dgoss run my-app:test
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
- [ ] README.md existiert
- [ ] Lokal gebaut und getestet
- [ ] Commit Messages folgen Conventional Commits

## 🙏 Danke!

Dein Beitrag macht dieses Projekt besser! 🎉
