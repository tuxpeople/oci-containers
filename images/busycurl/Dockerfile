# busycurl - busybox with a static curl (HTTPS, HTTP/2, SFTP/SCP)

# Build a fully static curl from the signed upstream release
FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS build

# VERSION: curl version, passed by the workflow from get-version.sh
ARG VERSION

# build.sh: originally from https://github.com/moparisthebest/static-curl
COPY build.sh /build.sh
# Daniel Stenberg's GPG keys for verifying curl releases: https://daniel.haxx.se/address.html
COPY mykey.asc /mykey.asc
WORKDIR /
RUN /build.sh "${VERSION}"

FROM busybox:1.38.0-musl@sha256:80e38f9a1b39188b8bdb28879178edb322a4402b081a9aedda1924609decd6f6

# OCI Labels
LABEL org.opencontainers.image.title="busycurl"
LABEL org.opencontainers.image.description="busybox 1.38 (musl) with a static curl"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

# The curl version the image was built for (also checked by goss.yaml)
ARG VERSION
ENV CURL_VERSION=${VERSION}

COPY --from=build /tmp/release/curl /usr/local/bin/curl
# busybox ships no CA bundle; without it every HTTPS request fails (curl exit 77)
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# nobody
USER 65534:65534

# Keep container running for Goss tests and interactive use; run curl with
# e.g. `docker run --rm busycurl curl -fsS https://example.com`
CMD ["sleep", "infinity"]
