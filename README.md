# OCI Containers 🐳

Zentrale Container-Registry für alle meine OCI-Images. Gebaut mit Best Practices für Security, Qualität und Wartbarkeit.

## 🎯 Features

- ✅ **Hadolint** - Dockerfile Linting
- ✅ **Trivy** - Vulnerability Scanning mit SARIF Upload
- ✅ **Cosign** - Keyless Image Signing
- ✅ **SBOM & Provenance** - Supply Chain Security
- ✅ **Multi-Arch** - AMD64 & ARM64 Support
- ✅ **Auto-Tagging** - Semantic Versioning via Git Tags
- ✅ **Goss Testing** - Mandatory Runtime Validation
- ✅ **Renovate** - Automatische Dependency Updates
- ✅ **Dual Registry** - GHCR + Docker Hub

## 📦 Verfügbare Images

| Image | Description | Registries |
|-------|-------------|------------|
| [example-app](./images/example-app) | Example container | [GHCR](https://ghcr.io/tuxpeople/example-app) • [Docker Hub](https://hub.docker.com/r/tdeutsch/example-app) |

## 🚀 Neues Image hinzufügen

### 1. Verzeichnis erstellen

```bash
mkdir -p images/my-app
cd images/my-app
```

### 2. Dockerfile erstellen

```dockerfile
FROM alpine:3.19

LABEL org.opencontainers.image.title="my-app"
LABEL org.opencontainers.image.description="Meine App"

RUN apk add --no-cache bash curl

USER 1000

CMD ["/bin/bash"]
```

### 3. README.md erstellen

```markdown
# my-app

Beschreibung deiner App.

## Usage

\`\`\`bash
docker run -it ghcr.io/tuxpeople/my-app:latest
\`\`\`
```

### 4. Goss Tests erstellen (PFLICHT)

Erstelle `goss.yaml` für automatische Tests:

```yaml
package:
  bash:
    installed: true

command:
  bash --version:
    exit-status: 0
```

**Wichtig:** Container muss für Tests laufen:

```dockerfile
CMD ["sleep", "infinity"]  # Nicht CMD ["/bin/bash"]!
```

### 5. Commit & Push

```bash
git add images/my-app
git commit -m "feat(my-app): add new container image"
git push
```

Der Workflow erkennt automatisch neue Images und baut sie.

## 🔐 Security

### Vulnerability Scanning

Jedes Image wird mit Trivy gescannt:
- **CRITICAL & HIGH** Vulnerabilities werden gemeldet
- Ergebnisse werden zu GitHub Security hochgeladen
- SARIF Format für Code Scanning Integration

### Image Signing

Alle Images werden mit Cosign (keyless) signiert:

```bash
# Verify image signature
cosign verify \
  --certificate-identity-regexp="https://github.com/tuxpeople" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/tuxpeople/my-app:latest
```

### SBOM & Provenance

- SBOM wird automatisch generiert
- Provenance Attestation für Supply Chain Security
- Verfügbar via Docker Buildx

## 🔄 Updates

### Automatisch via Renovate

Renovate überwacht:
- Base Images (z.B. `alpine:3.19` → `alpine:3.20`)
- GitHub Actions Versionen
- Dependencies in Dockerfiles

### Manuell

```bash
# Bump version und release
git tag my-app-v1.2.3
git push --tags
```

## 🏗️ Build-Matrix

Die Pipeline baut automatisch nur geänderte Images:

- **On Push**: Nur Images in geänderten Ordnern
- **On Schedule**: Alle Images (nightly)
- **On Manual**: Alle Images

## 📋 Workflow-Übersicht

### Build & Release (`build-release.yml`)

```
1. Detect Changes  ─→  2. Hadolint  ─→  3. Build
                                           │
                                           ↓
4. Trivy Scan  ←─────  5. Cosign Sign  ←──┘
     │
     ↓
6. Push to GHCR + Docker Hub
```

### PR Validation (`pr-validate.yml`)

```
1. Detect Changes  ─→  2. Hadolint  ─→  3. Build (no push)
                                           │
                                           ↓
                                      4. Trivy Scan
                                           │
                                           ↓
                                      5. Goss Tests (optional)
```

## 🛠️ Lokale Entwicklung

### Build lokal

```bash
docker build -t my-app:test ./images/my-app
```

### Test mit Goss

```bash
# Install dgoss
curl -L https://raw.githubusercontent.com/goss-org/goss/master/extras/dgoss/dgoss -o /usr/local/bin/dgoss
chmod +x /usr/local/bin/dgoss

# Run tests
GOSS_FILE=images/my-app/goss.yaml dgoss run my-app:test
```

### Lint Dockerfile

```bash
docker run --rm -i hadolint/hadolint < images/my-app/Dockerfile
```

### Scan mit Trivy

```bash
trivy image my-app:test
```

## 📚 Dokumentation

- [Hadolint Rules](https://github.com/hadolint/hadolint#rules)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Cosign Documentation](https://docs.sigstore.dev/cosign/overview/)
- [Goss Documentation](https://github.com/goss-org/goss/blob/master/docs/manual.md)

## 🔧 Secrets Configuration

Folgende Secrets müssen in GitHub konfiguriert sein:

| Secret | Beschreibung | Erforderlich |
|--------|--------------|--------------|
| `DOCKERHUB_TOKEN` | Docker Hub Access Token | Ja |
| `GITHUB_TOKEN` | Automatisch verfügbar | Automatisch |

Setup:
1. GitHub → Settings → Secrets and variables → Actions
2. "New repository secret"
3. Name: `DOCKERHUB_TOKEN`
4. Value: Dein Docker Hub Token

## 📝 Best Practices

### Dockerfile

- ✅ Immer spezifische Tags verwenden (`alpine:3.19` statt `alpine:latest`)
- ✅ Non-root User verwenden
- ✅ Multi-stage builds für kleinere Images
- ✅ Layer caching optimieren
- ✅ `.dockerignore` verwenden

### Security

- ✅ Regelmässig Base Images updaten
- ✅ Trivy Scans beachten
- ✅ Minimale Packages installieren
- ✅ Secrets nie ins Image hardcoden

### Testing

- ✅ **Goss Tests für alle Images** - Keine Ausnahmen ohne Begründung
- ✅ Health Checks definieren
- ✅ Container muss laufen: `CMD ["sleep", "infinity"]`
- ✅ Lokal testen vor Push

## 🐛 Troubleshooting

### Build failed - Hadolint

```bash
# Lokal prüfen
hadolint images/my-app/Dockerfile

# Regel ignorieren (falls notwendig)
# Füge zu .hadolint.yaml hinzu:
ignored:
  - DL3018
```

### Build failed - Trivy

```bash
# Lokal scannen
trivy image my-app:test

# Vulnerability ignorieren (nur wenn gerechtfertigt)
# Erstelle images/my-app/.trivyignore:
CVE-2024-1234
```

### Image nicht signiert

```bash
# Check Cosign logs in GitHub Actions
# Stelle sicher dass GITHUB_TOKEN Permissions korrekt sind
```

## 📊 Status

![Build Status](https://github.com/tuxpeople/oci-containers/workflows/Build%20&%20Release/badge.svg)

## 🤝 Contributing

1. Fork das Repo
2. Erstelle einen Feature Branch
3. Committe deine Änderungen
4. Push den Branch
5. Öffne einen Pull Request

## 📄 License

MIT License - siehe [LICENSE](LICENSE) file
