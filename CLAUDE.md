# CLAUDE.md - AI Assistant Guidelines for oci-containers

This document provides context and guidelines for AI assistants (like Claude) working on this repository.

## 📋 Project Overview

**Repository:** oci-containers  
**Purpose:** Centralized OCI container images with security-first Golden Pipeline  
**Owner:** Thomas Deutsch (@tuxpeople)  
**Tech Stack:** Docker, GitHub Actions, Hadolint, Trivy, Cosign, Goss

## 🎯 Project Goals

1. **Consolidation:** Single source of truth for all container images (previously scattered across 7+ repos)
2. **Security:** Every image gets Hadolint, Trivy, Cosign, SBOM, and Provenance
3. **Consistency:** One workflow, one structure, no surprises
4. **Simplicity:** ADHD-friendly - easy to add new images, easy to maintain
5. **Automation:** Minimal manual work - Renovate, auto-tagging, scheduled builds

## 🏗️ Repository Structure

```
oci-containers/
├── .github/
│   ├── workflows/
│   │   ├── build-release.yml        # Golden Pipeline (main)
│   │   ├── pr-validate.yml          # PR validation
│   │   └── auto-assign-issues.yaml  # Issue management
│   └── ISSUE_TEMPLATE/              # Bug & Feature templates
├── images/                          # Container images directory
│   └── {image-name}/
│       ├── Dockerfile               # Required
│       ├── README.md                # Required
│       ├── goss.yaml               # Optional: Runtime tests
│       └── .trivyignore            # Optional: CVE exceptions
├── .hadolint.yaml                   # Hadolint configuration
├── renovate.json                    # Dependency updates
├── README.md                        # Main documentation
├── QUICKSTART.md                    # 5-minute guide
├── CONTRIBUTING.md                  # Contribution guidelines
├── SETUP.md                         # Initial setup guide
└── CLAUDE.md                        # This file
```

## 📚 Documentation Update Policy

**CRITICAL**: Every code change MUST be evaluated for documentation impact.

### Before Committing ANY Change

Ask yourself: **"Does this require documentation updates?"**

### Documentation Files to Check

| File | When to Update |
|------|---------------|
| `README.md` | User-facing changes, new features, setup instructions |
| `QUICKSTART.md` | Quick start flow changes, new image examples |
| `CONTRIBUTING.md` | Workflow changes, new requirements, process updates |
| `SETUP.md` | Initial setup process changes |
| `.github/workflows/*.yml` | Workflow behavior changes (document in comments) |
| `images/{name}/README.md` | Image-specific usage or configuration changes |
| `CLAUDE.md` | Project standards, architecture decisions |

### Documentation Commit Rules

- ✅ **DO:** Commit documentation updates together with code changes
- ✅ **DO:** Update all affected documentation files in the same commit
- ✅ **DO:** Add inline comments for complex workflow changes
- ❌ **DON'T:** Commit code without updating related documentation
- ❌ **DON'T:** Leave outdated documentation

### Example

```bash
# GOOD - Code + Docs in same commit
git add .github/workflows/build-release.yml
git add README.md  # Updated to reflect workflow change
git commit -m "feat: add Discord notifications to build workflow

- Add Discord webhook integration
- Update README.md with notification setup
- Add DISCORD_WEBHOOK secret to docs"

# BAD - Code only, docs forgotten
git add .github/workflows/build-release.yml
git commit -m "feat: add Discord notifications"
# ❌ README.md still shows old behavior!
```

## 🔧 Git Commit Standards

### Commit Message Format

**CRITICAL:** Commit messages control automatic versioning!

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types & Versioning:**

| Type | Version Bump | Use Case |
|------|--------------|----------|
| `feat` | **Minor** (0.1.0 → 0.2.0) | New features |
| `fix` | **Patch** (0.1.0 → 0.1.1) | Bug fixes |
| `feat!` | **Major** (0.1.0 → 1.0.0) | Breaking changes |
| `chore` | **Patch** | Dependencies, maintenance |
| `docs` | None | Documentation only |
| `refactor` | None | Code restructuring |
| `test` | None | Test updates |
| `ci` | None | CI/CD changes |

**Scopes:**
- `{image-name}`: Specific image changes (e.g., `nginx`, `postgres`)
- `workflow`: GitHub Actions workflows
- `docs`: Documentation
- `deps`: Dependencies

### Breaking Changes

For Major version bumps (1.0.0 → 2.0.0):

```bash
# Option 1: Exclamation mark
feat(myapp)!: change authentication method

# Option 2: BREAKING CHANGE in footer
feat(myapp): change authentication method

BREAKING CHANGE: API keys no longer supported, use OAuth2
```

### Examples

```bash
# New image
feat(debugcontainer): add debug container image

# Workflow improvement
ci(workflow): add Trivy SARIF upload

# Documentation
docs(readme): update security scanning section

# Multiple images
feat(nginx,postgres): add health checks

# Dependency update
chore(deps): update alpine base to 3.20
```

### **IMPORTANT: No AI Signatures in Commits!**

❌ **NEVER include:**
- AI-generated signatures ("Generated by Claude", "AI-assisted")
- Tool attributions in commit messages
- References to AI assistance

✅ **Commits should be:**
- Written as if by the human developer
- Professional and concise
- Focused on the change, not the tool

```bash
# ❌ BAD
git commit -m "feat: add new image

Generated by Claude AI
Co-authored-by: Claude"

# ✅ GOOD
git commit -m "feat(myapp): add myapp container image

- Alpine 3.19 base
- Non-root user
- Health checks included"
```

## 🔐 Security Standards

### Dockerfile Requirements

**MUST have:**
- Specific base image tags (never `:latest`)
- **OCI labels (ALL REQUIRED):**
  - `org.opencontainers.image.title`
  - `org.opencontainers.image.description`
  - `org.opencontainers.image.vendor="tuxpeople"`
  - `org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"`
- Non-root user (`USER 1000` or higher)
- `CMD ["sleep", "infinity"]` for Goss compatibility
- Health checks (if image exposes ports)

**Example:**
```dockerfile
FROM alpine:3.19

# OCI Labels (ALLE PFLICHT!)
LABEL org.opencontainers.image.title="my-app"
LABEL org.opencontainers.image.description="My application"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

RUN apk add --no-cache bash

USER 1000

CMD ["sleep", "infinity"]
```

**Note:** Additional labels (created, revision, version, licenses, url) are set automatically by the build workflow.

**SHOULD have:**
- Multi-stage builds (for smaller images)
- Minimal package installations
- No unnecessary tools

**MUST NOT have:**
- Secrets or credentials
- Root user in runtime
- Latest/floating tags

### Security Scanning

Every image must pass:
- **Hadolint:** Dockerfile linting (warnings allowed, errors fail)
- **Trivy:** No CRITICAL or HIGH CVEs (unless documented in `.trivyignore`)
- **Cosign:** Automatic keyless signing (post-build)

### CVE Exceptions

If a CVE must be ignored:

1. Create `.trivyignore` in image directory
2. Document WHY (not just what)
3. Reference source/discussion

```bash
# images/myapp/.trivyignore
CVE-2024-1234
# Reason: Library only used at build time, not in runtime
# Source: https://github.com/alpine/alpine/issues/...
```

## 🧪 Testing Standards

### Mandatory Testing (Required for ALL Images)

1. **Hadolint** - Dockerfile linting must pass (errors fail build)
2. **Image Build** - Must build successfully for all platforms
3. **Trivy Scan** - No CRITICAL or HIGH CVEs (unless documented)
4. **Goss Tests** - Runtime validation tests are **MANDATORY**

**Every image MUST have `goss.yaml`** unless technically impossible.

### Goss Test Requirements

Create `images/{name}/goss.yaml` with at minimum:
- Package installation verification
- Basic command functionality
- File existence checks
- User/permission validation

**Exception Policy:** Goss tests can only be omitted if:
- Container has no packages to test (e.g., scratch-based)
- Container requires external dependencies unavailable in CI
- Technical limitation documented in image README

**Container CMD for Goss:**

Container must stay running during tests:

```dockerfile
# ✅ REQUIRED - Container stays alive for Goss
CMD ["sleep", "infinity"]
# or
CMD ["tail", "-f", "/dev/null"]

# ❌ FORBIDDEN - Container exits immediately
CMD ["/bin/bash"]  # Exits without interactive terminal
```

For interactive use, override CMD:
```bash
docker run -it myimage /bin/bash
```

### Additional Testing (Optional)

**Custom Tests** - Add `test.sh` for:
- Complex integration tests
- Multi-container scenarios  
- External service dependencies
- Custom validation logic beyond Goss capabilities

## 🔄 Workflow Behavior

### Build Triggers

| Trigger | Builds | Push to Registry |
|---------|--------|------------------|
| Push to main (changed images) | Only changed | Yes (GHCR + Docker Hub) |
| Schedule (nightly) | All images | Yes |
| Manual (workflow_dispatch) | All images | Yes |
| Pull Request | Changed images | No (build only) |
| Git Tag `{image}-v*` | Tagged image | Yes |

### Image Tagging Strategy

**On Git Tag** `myapp-v1.2.3`:
- `myapp:latest` (latest stable release)
- `myapp:1.2.3` (exact version)
- `myapp:1.2` (minor - **floating**, updates to 1.2.4)
- `myapp:1` (major - **floating**, updates to 1.3.0)

**On Push to main:**
- `myapp:main` (bleeding edge)
- `myapp:sha-{short-sha}` (commit reference)

**On Schedule:**
- `myapp:nightly`

**Important:**
- `:latest` = Latest **stable** version (only on releases)
- `:main` = Latest **main** branch (may be untested)
- `:1` and `:1.2` are **floating** tags (overwritten by newer versions in same major/minor)
- Production should use pinned tags (`:1.2.3` or `:1.2`)
- Development can use `:main`

## 🤖 Working with AI Assistants

### When Adding New Images

1. **Check existing patterns** - Look at `images/example-app` first
2. **Follow structure** - Dockerfile + README.md minimum
3. **Test locally** before pushing
4. **Update docs** if new patterns introduced

### When Modifying Workflows

1. **Understand the full pipeline** - Read workflow comments
2. **Test in PR first** - Never push directly to main
3. **Consider impact** - One workflow change affects ALL images
4. **Document inline** - Add comments explaining WHY

### When Troubleshooting

1. **Check GitHub Actions logs** - Most issues are visible there
2. **Test locally** - Reproduce the exact build steps
3. **Read error messages** - Hadolint/Trivy output is usually clear
4. **Check secrets** - DOCKERHUB_TOKEN configured?

## 🎨 Code Style

### Dockerfile Style

```dockerfile
# ✅ GOOD - Clear, organized, commented
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    curl \
    vim \
    && rm -rf /var/cache/apk/*

# Create application user
RUN addgroup -g 1000 app && \
    adduser -D -u 1000 -G app app

USER app

# ❌ BAD - Messy, unclear
FROM alpine
RUN apk add bash curl vim && rm -rf /var/cache/apk/*
RUN addgroup -g 1000 app && adduser -D -u 1000 -G app app
USER app
```

### YAML Style (Workflows)

- Use 2-space indentation
- Add comments for complex steps
- Group related steps with headers
- Use descriptive step names

## 🚫 Common Pitfalls to Avoid

### 1. Forgetting Documentation
❌ Code change without README update  
✅ Update docs in same commit

### 2. Using `latest` Tags
❌ `FROM alpine:latest`  
✅ `FROM alpine:3.19`

### 3. Running as Root
❌ No `USER` directive  
✅ `USER 1000`

### 4. Missing Goss Tests
❌ No `goss.yaml` file  
✅ Create `goss.yaml` with minimum tests

### 5. Wrong CMD for Goss
❌ `CMD ["/bin/bash"]` (exits immediately)  
✅ `CMD ["sleep", "infinity"]` (stays running)

### 6. Ignoring Trivy CVEs
❌ Ignoring without explanation  
✅ Document in `.trivyignore` with reason

### 7. Breaking Changes Without Warning
❌ Change workflow behavior silently  
✅ Document in PR, update docs, consider migration path

### 8. Complex Solutions
❌ Over-engineering for one image  
✅ Keep it simple - ADHD-friendly is the goal!

## 🔍 Quality Checklist

Before submitting PR or committing:

- [ ] Documentation updated?
- [ ] Hadolint passes locally?
- [ ] Image builds successfully?
- [ ] **Goss tests created** (`goss.yaml` present)?
- [ ] **Goss tests pass** locally (`dgoss run`)?
- [ ] Commit message follows Conventional Commits?
- [ ] No AI signatures in commits?
- [ ] README.md reflects changes?
- [ ] No secrets in code?
- [ ] Followed existing patterns?

## 💡 Design Principles

### 1. **Simplicity Over Complexity**
One simple solution for all images, not complex per-image configs.

### 2. **Security by Default**
Every image gets full security pipeline, no exceptions.

### 3. **Documentation is Code**
Outdated docs are bugs. Fix them like bugs.

### 4. **ADHD-Friendly**
- Clear structure
- Consistent patterns
- Minimal cognitive load
- Easy to resume after breaks

### 5. **Fail Fast, Fix Fast**
Better to catch issues in CI than in production.

## 📞 Getting Help

If stuck or unsure:

1. Check existing images for patterns
2. Read workflow comments
3. Review GitHub Actions logs
4. Check Obsidian docs: `🏠 Homelab/Container-Images-Strategie.md`
5. Create GitHub Discussion (not Issue)

## 🗺️ Roadmap Considerations

When suggesting improvements:

- **Keep it simple** - Complexity is the enemy
- **Maintain consistency** - Changes should work for ALL images
- **Consider maintenance** - Who will maintain this in 6 months?
- **Document thoroughly** - Future-you will thank you

## 📝 File Maintenance

### README.md
Keep updated with:
- Available images table
- Feature list
- Quick start instructions

### SETUP.md
Only update for:
- Initial setup process changes
- New secret requirements
- Major workflow changes

### QUICKSTART.md
Update when:
- Minimal example changes
- Common commands change
- 5-minute flow is no longer 5 minutes

## 🎓 Learning Resources

Understanding this repo requires knowledge of:

- Docker & Dockerfiles
- GitHub Actions
- OCI Image Spec
- Supply Chain Security (SLSA, SBOM, Provenance)
- Container Security (Trivy, Cosign)

Recommended reading:
- [Hadolint Best Practices](https://github.com/hadolint/hadolint)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Cosign Keyless Signing](https://docs.sigstore.dev/cosign/signing/overview/)
- [SLSA Framework](https://slsa.dev/)

---

**Last Updated:** 2024-12-21  
**Version:** 1.0  
**Maintained by:** Thomas Deutsch (@tuxpeople)
