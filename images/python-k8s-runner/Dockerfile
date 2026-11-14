# Minimal Python runtime for scripts that are mounted into the container from
# outside (e.g. via ConfigMap in Kubernetes). Only the packages listed in
# requirements.txt are installed, the script itself is not part of the image.

# Build the virtualenv using Chainguard's Python dev image (pip, build tools)
# DL3007: Chainguard only publishes `latest` tags for free. The digest is
# pinned, so Renovate proposes base image updates as PRs that have to pass CI.
# hadolint ignore=DL3007
FROM cgr.dev/chainguard/python:latest-dev@sha256:1aad742e9c8ea5597520fe43ae154e0160fb8364485506945f7de6cd7879beea AS build

COPY requirements.txt /tmp/requirements.txt
RUN python -m venv /home/nonroot/venv && \
    /home/nonroot/venv/bin/pip install --disable-pip-version-check --no-cache-dir -r /tmp/requirements.txt && \
    # pip/setuptools are never used at runtime (no shell in the distroless
    # image) and would only add CVE findings to the final image
    /home/nonroot/venv/bin/pip uninstall --yes pip setuptools wheel

# Copy the virtualenv into the minimal distroless Chainguard Python runtime
# hadolint ignore=DL3007
FROM cgr.dev/chainguard/python:latest@sha256:b194f818c3fbf172c83597753e72561f14f58d22e9ea6bf148b7597246f65c8f

# OCI Labels
LABEL org.opencontainers.image.title="python-k8s-runner"
LABEL org.opencontainers.image.description="Minimal distroless Python runtime for scripts mounted from outside"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

COPY --from=build /home/nonroot/venv /home/nonroot/venv

# PYTHONUNBUFFERED: log output straight to stdout/stderr so kubectl logs shows it immediately
# PYTHONDONTWRITEBYTECODE: mounted scripts usually live on a read-only volume
ENV PATH="/home/nonroot/venv/bin:$PATH" \
    VIRTUAL_ENV="/home/nonroot/venv" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Chainguard's nonroot user
USER 65532
WORKDIR /app

# No CMD ["sleep", "infinity"]: the distroless image has no shell and no
# sleep binary, the script to run is passed as argument (see README.md)
ENTRYPOINT ["python"]
