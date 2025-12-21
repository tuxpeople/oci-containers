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

CMD ["sleep", "infinity"]
```

### 3. README erstellen

```markdown
# my-app

Short description of your app.

## Usage

\`\`\`bash
docker run -it --rm ghcr.io/tuxpeople/my-app:latest /bin/bash
\`\`\`
```

### 4. Goss Tests (PFLICHT!)

Erstelle `images/my-app/goss.yaml`:

```yaml
package:
  bash:
    installed: true

command:
  bash --version:
    exit-status: 0
```

**Container CMD:**
```dockerfile
CMD ["sleep", "infinity"]  # Nicht /bin/bash!
```

### 5. Commit & Push

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

## 🏷️ Automatisches Versioning

**Commit Messages steuern Versionen!**

```bash
# Fix → Patch bump (1.0.0 → 1.0.1)
git commit -m "fix(my-app): fix startup bug"

# Feature → Minor bump (1.0.0 → 1.1.0)
git commit -m "feat(my-app): add metrics endpoint"

# Breaking Change → Major bump (1.0.0 → 2.0.0)
git commit -m "feat(my-app)!: change API"
```

**Erster Commit erstellt `v0.1.0`:**

```bash
git commit -m "feat(my-app): add new container"
# → Automatisch: my-app-v0.1.0
```

**Entstehende Tags:**

Bei `my-app-v1.2.3`:
- `my-app:latest` (neueste stabile)
- `my-app:1.2.3` (exakte Version)
- `my-app:1.2` (floating minor)
- `my-app:1` (floating major)

Ohne Release (nur Push):
- `my-app:main` (bleeding edge)
- `my-app:sha-abc1234` (commit)
- `my-app:nightly` (scheduled)

**Tipp:**
- Production: `:1.2.3` oder `:1.2` (pinned)
- Development: `:main` (neuester Code)
- Stable: `:latest` (neueste Version)

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
