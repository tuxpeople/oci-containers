# python-k8s-runner

Minimal distroless Python runtime for scripts that are mounted into the container from outside, e.g. via ConfigMap in Kubernetes.

## Features

- **Distroless** Chainguard Python base (no shell, no package manager)
- **Multi-stage build** - packages are installed in the dev image, only the virtualenv is copied into the runtime
- **Multi-Architecture** support (amd64, arm64)
- **Non-root user** (`nonroot`, UID 65532)
- Works with a read-only root filesystem

## Usage

The image does not contain a script. `python` is the entrypoint, the script to run is passed as argument.

### Docker

```bash
docker run --rm --read-only \
  -v $(pwd)/scripts:/app:ro \
  ghcr.io/tuxpeople/python-k8s-runner:latest \
  script.py
```

### Kubernetes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: python-k8s-runner
spec:
  containers:
    - name: runner
      image: ghcr.io/tuxpeople/python-k8s-runner:latest
      args: ["/app/script.py"]
      securityContext:
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
      volumeMounts:
        - name: script
          mountPath: /app
          readOnly: true
        # Only needed if the script writes temporary files
        # - name: tmp
        #   mountPath: /tmp
  volumes:
    - name: script
      configMap:
        name: my-script
    # - name: tmp
    #   emptyDir: {}
```

## Installed Packages

See [requirements.txt](./requirements.txt).

## Environment

| Variable | Value | Purpose |
|----------|-------|---------|
| `PYTHONUNBUFFERED` | `1` | Output shows up in `kubectl logs` immediately |
| `PYTHONDONTWRITEBYTECODE` | `1` | No `.pyc` files next to read-only mounted scripts |

## Testing

This image has **no Goss tests** and no `CMD ["sleep", "infinity"]`. This is a technical limitation: the distroless runtime has no shell and no `sleep` binary, and dgoss needs a shell inside the container to run goss. The image is validated by Hadolint, the multi-arch build and the Trivy scan.

Check locally that a script runs:

```bash
docker build -t python-k8s-runner:test ./images/python-k8s-runner
docker run --rm --read-only -v $(pwd)/scripts:/app:ro python-k8s-runner:test script.py
```

## Image Tags

- `latest` - Latest stable release
- `X.Y.Z` - Specific version
- `X.Y` - Minor version (floating)
- `X` - Major version (floating)
- `main` - Latest build from main branch
- `nightly` - Nightly build

## Security

- Runs as non-root user `nonroot` (UID 65532)
- No shell, no package manager, no pip in the runtime image
- Base images pinned by digest, updated via Renovate
- Regular security scans with Trivy
- Signed with Cosign

## Links

- [Chainguard Python Image](https://images.chainguard.dev/directory/image/python/overview)
- [GitHub Repository](https://github.com/tuxpeople/oci-containers)
- [Image Registry (GHCR)](https://ghcr.io/tuxpeople/python-k8s-runner)
- [Image Registry (Docker Hub)](https://hub.docker.com/r/tdeutsch/python-k8s-runner)
