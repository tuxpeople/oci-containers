# jdownloader-headless - JDownloader 2 without GUI, controlled via MyJDownloader
# Originally by Jay Moulin: https://github.com/jaymoulin/docker-jdownloader (MIT)

FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

# OCI Labels
LABEL org.opencontainers.image.title="jdownloader-headless"
LABEL org.opencontainers.image.description="JDownloader 2 without GUI, controlled via MyJDownloader"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"
LABEL org.opencontainers.image.licenses="MIT"

ARG TARGETARCH

# Java 21 where Alpine has it; armv7 only has OpenJDK 8 (still maintained).
# ffmpeg: merging audio/video streams, fonts: captcha rendering,
# libstdc++: sevenzipjbinding (archive extraction), jq: settings
# hadolint ignore=DL3018
RUN if [ "${TARGETARCH}" = "arm" ]; then java=openjdk8-jre; else java=openjdk21-jre-headless; fi && \
    apk upgrade --no-cache && \
    apk add --no-cache "$java" ca-certificates curl ffmpeg fontconfig font-dejavu jq libstdc++ tini && \
    mkdir -p /opt/JDownloader && \
    # Any UID must be able to run it (docker -u, Kubernetes runAsUser)
    chmod 777 /opt/JDownloader

COPY libs/${TARGETARCH}/ /usr/local/share/jdownloader/libs/
COPY myjdownloader-settings.json.dist /usr/local/share/jdownloader/
COPY --chmod=755 entrypoint.sh /usr/local/bin/jdownloader

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    XDG_DOWNLOAD_DIR=/opt/JDownloader/Downloads

USER 1000
WORKDIR /opt/JDownloader
EXPOSE 3129

# tini reaps zombie processes and passes stop signals to the start script
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jdownloader"]
