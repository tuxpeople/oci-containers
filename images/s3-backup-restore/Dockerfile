# s3-backup-restore - back up a folder to S3 and restore it (bloveless/docker-images)
# https://github.com/bloveless/docker-images/tree/main/s3-backup-restore

# Build on the runner's platform and cross-compile: no QEMU emulation needed
FROM --platform=$BUILDPLATFORM golang:1.27.3-alpine3.24@sha256:d200d2dd76b03a99b52651fd1325aff7dcd35422c35c01bac56571b0507f3deb AS build

# VERSION: git-<sha> of the last upstream commit touching s3-backup-restore/
# (from get-version.sh); exactly that commit is built
ARG VERSION
ARG TARGETOS
ARG TARGETARCH

# hadolint ignore=DL3018
RUN apk add --no-cache git

WORKDIR /src
RUN test -n "${VERSION}" && \
    git clone --quiet https://github.com/bloveless/docker-images.git . && \
    git checkout --quiet "${VERSION#git-}"

WORKDIR /src/s3-backup-restore
RUN go mod download && \
    CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" \
      go build -trimpath -ldflags "-s -w" -o /out/s3-backup-restore ./cmd/s3-backup-restore

# Distroless static runtime: no shell, runs as nonroot (UID 65532)
FROM gcr.io/distroless/static-debian13:nonroot@sha256:25ac8f0c3b2334a9eb05452266bd4697864a8c8ef0ef71e5e6480d7f92868329

# OCI Labels
LABEL org.opencontainers.image.title="s3-backup-restore"
LABEL org.opencontainers.image.description="Back up a folder to S3 on a schedule and restore it, on a distroless static base"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

COPY --from=build /out/s3-backup-restore /usr/local/bin/s3-backup-restore

USER 65532

ENTRYPOINT ["/usr/local/bin/s3-backup-restore"]
CMD ["cron"]
