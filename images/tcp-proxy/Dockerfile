# tcp-proxy - relay TCP connections to another host and port with socat
# Based on https://github.com/hpello/tcp-proxy-docker

FROM alpine:3.24.4@sha256:93b41ef40b1677fce8fcc64ff4af09daddfacf5040afde618bc46c1e2d1cc7d4

# OCI Labels
LABEL org.opencontainers.image.title="tcp-proxy"
LABEL org.opencontainers.image.description="Relay TCP connections to another host and port with socat"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

# hadolint ignore=DL3018
RUN apk upgrade --no-cache && \
    apk add --no-cache socat && \
    adduser -D -u 1001 appuser

COPY tcp-proxy.sh /usr/local/bin/tcp-proxy

USER 1001

# No CMD ["sleep", "infinity"]: the container is a service that needs a
# target; test.sh starts it against a test backend instead of using Goss
ENTRYPOINT ["/usr/local/bin/tcp-proxy"]
