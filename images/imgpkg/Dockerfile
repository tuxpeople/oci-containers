# imgpkg (Carvel) - store application configuration as OCI images
# https://github.com/carvel-dev/imgpkg

FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS downloader

# VERSION: passed by the workflow from get-version.sh (latest upstream release)
ARG VERSION
ARG TARGETOS
ARG TARGETARCH

# hadolint ignore=DL3018
RUN apk add --no-cache curl

# Download the release binary and verify it against the published checksums
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
WORKDIR /tmp/imgpkg
RUN test -n "${VERSION}" && \
    base="https://github.com/carvel-dev/imgpkg/releases/download/v${VERSION}" && \
    binary="imgpkg-${TARGETOS}-${TARGETARCH}" && \
    curl -fsSLO "${base}/${binary}" && \
    curl -fsSLO "${base}/checksums.txt" && \
    grep " ${binary}\$" checksums.txt | sha256sum -c - && \
    install -m 0755 "${binary}" /usr/local/bin/imgpkg

# Distroless static runtime: no shell, runs as nonroot (UID 65532)
FROM gcr.io/distroless/static-debian13:nonroot@sha256:25ac8f0c3b2334a9eb05452266bd4697864a8c8ef0ef71e5e6480d7f92868329

# OCI Labels
LABEL org.opencontainers.image.title="imgpkg"
LABEL org.opencontainers.image.description="Carvel imgpkg CLI on a distroless static base"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

COPY --from=downloader /usr/local/bin/imgpkg /usr/local/bin/imgpkg

USER 65532

# No CMD ["sleep", "infinity"]: distroless has no sleep and no shell, so the
# image is tested with test.sh instead of Goss
ENTRYPOINT ["/usr/local/bin/imgpkg"]
CMD ["--help"]
