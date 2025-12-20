# Quick Start Guide

Schnelleinstieg für neue Container-Images in 5 Minuten.

## 🚀 Sofort loslegen

### 1. Neues Image erstellen

```bash
# Image-Verzeichnis
mkdir -p images/my-app
cd images/my-app
```

### 2. Minimal-Dockerfile

```dockerfile
FROM alpine:3.19

LABEL org.opencontainers.image.title="my-app"
LABEL org.opencontainers.image.description="My awesome app"

RUN apk add --no-cache bash curl

USER 1000

CMD ["/bin/bash"]
```

### 3. README erstellen

```markdown
# my-app

Short description of your app.

## Usage

\`\`\`bash
docker run -it ghcr.io/tuxpeople/my-app:latest
\`\`\`
```

### 4. Commit & Push

```bash
git add images/my-app
git commit -m "feat(my-app): add new container"
git push
```

**Fertig!** Die Pipeline baut, testet und veröffentlicht automatisch.

## 🧪 Lokal testen

```bash
# Lint
hadolint images/my-app/Dockerfile

# Build
docker build -t my-app:test ./images/my-app

# Scan
trivy image my-app:test

# Run
docker run -it my-app:test
```

## 🔍 Image finden

Nach erfolgreichem Build:

- **GHCR:** `ghcr.io/tuxpeople/my-app:latest`
- **Docker Hub:** `docker.io/tdeutsch/my-app:latest`

## 🎯 Optional: Goss Tests

Erstelle `images/my-app/goss.yaml`:

```yaml
package:
  bash:
    installed: true

command:
  bash --version:
    exit-status: 0
```

## 🏷️ Versionen taggen

```bash
# Tag erstellen (image-name-vX.Y.Z)
git tag my-app-v1.0.0
git push --tags
```

Dies erzeugt:
- `my-app:1.0.0`
- `my-app:1.0`
- `my-app:1`
- `my-app:latest`

## 📚 Mehr Info

- [README.md](README.md) - Vollständige Dokumentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution Guidelines

## ⚡ Häufige Aufgaben

### Image updaten

```bash
# Dockerfile ändern
vim images/my-app/Dockerfile

# Commit
git commit -am "fix(my-app): update base image"
git push
```

### CVE ignorieren

```bash
# Nur wenn gerechtfertigt!
echo "CVE-2024-xxx" > images/my-app/.trivyignore
echo "# Reason: Package not used" >> images/my-app/.trivyignore
```

### Workflow re-triggern

```bash
# Leerer Commit
git commit --allow-empty -m "chore(my-app): rebuild"
git push
```

## 🆘 Hilfe

- GitHub Issues: Problem melden
- GitHub Discussions: Fragen stellen
- Workflow Logs: `gh run view --log`

---

**Tipp:** Kopiere `images/example-app` als Template für neue Images!
