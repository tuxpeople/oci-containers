# tinysyslog - tiny syslog server that writes to stdout (or files)
# https://github.com/alexferl/tinysyslog

# Build on the runner's platform and cross-compile: no QEMU emulation needed
FROM --platform=$BUILDPLATFORM golang:1.27.3-alpine3.24@sha256:fa3d596898d9f126af7c01d14ee7597bab3f39cccf392ef36b69fe77cd681f18 AS build

# VERSION: passed by the workflow from get-version.sh (latest upstream release)
ARG VERSION
ARG TARGETOS
ARG TARGETARCH

# hadolint ignore=DL3018
RUN apk add --no-cache git

WORKDIR /src
RUN test -n "${VERSION}" && \
    git clone --depth 1 --branch "v${VERSION}" https://github.com/alexferl/tinysyslog.git . && \
    go mod download && \
    CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" \
      go build -trimpath -ldflags "-s -w" -o /out/tinysyslogd ./cmd/tinysyslogd

# Distroless static runtime: no shell, runs as nonroot (UID 65532)
FROM gcr.io/distroless/static-debian13:nonroot@sha256:25ac8f0c3b2334a9eb05452266bd4697864a8c8ef0ef71e5e6480d7f92868329

# OCI Labels
LABEL org.opencontainers.image.title="tinysyslog"
LABEL org.opencontainers.image.description="Tiny syslog server (TCP/UDP 5140) that logs to stdout, on a distroless static base"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

COPY --from=build /out/tinysyslogd /usr/local/bin/tinysyslogd

USER 65532
EXPOSE 5140/tcp 5140/udp

# Unprivileged port (> 1024), so no capabilities are needed
ENTRYPOINT ["/usr/local/bin/tinysyslogd", "--bind-addr", "0.0.0.0:5140"]
