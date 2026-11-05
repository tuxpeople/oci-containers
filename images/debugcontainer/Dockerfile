# debugcontainer - Swiss army knife for debugging containers and Kubernetes:
# networking, storage, performance and cluster tools in one Alpine image
# Thanks to https://github.com/dbamaster/mssql-tools-alpine and
# https://github.com/ssro/dnsperf

FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS downloader

ARG TARGETOS
ARG TARGETARCH

# renovate: datasource=github-releases depName=fluxcd/flux2
ARG FLUX_VERSION=v2.10.0
# renovate: datasource=github-releases depName=carvel-dev/ytt
ARG YTT_VERSION=v0.55.4
# renovate: datasource=github-releases depName=carvel-dev/imgpkg
ARG IMGPKG_VERSION=v0.49.0
# renovate: datasource=github-releases depName=oras-project/oras
ARG ORAS_VERSION=v1.3.6
# renovate: datasource=custom.openshift-ocp depName=openshift/ocp versioning=semver
ARG OC_VERSION=4.22.21

# hadolint ignore=DL3018
RUN apk add --no-cache curl

# Every binary is verified against the checksums its release publishes
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
WORKDIR /tmp/dl
RUN mkdir -p /out && \
    gh="https://github.com" && \
    # verify <checksum file> <file>
    verify() { grep -E "[ *]$2\$" "$1" | sha256sum -c -; } && \
    # flux
    f="flux_${FLUX_VERSION#v}_${TARGETOS}_${TARGETARCH}.tar.gz" && \
    curl -fsSLO "${gh}/fluxcd/flux2/releases/download/${FLUX_VERSION}/${f}" && \
    curl -fsSL -o flux.sha256 "${gh}/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION#v}_checksums.txt" && \
    verify flux.sha256 "$f" && tar -xzf "$f" -C /out flux && \
    # ytt, imgpkg
    for tool in ytt:${YTT_VERSION} imgpkg:${IMGPKG_VERSION}; do \
      name="${tool%%:*}"; version="${tool#*:}"; f="${name}-${TARGETOS}-${TARGETARCH}"; \
      curl -fsSLO "${gh}/carvel-dev/${name}/releases/download/${version}/${f}" && \
      curl -fsSL -o "${name}.sha256" "${gh}/carvel-dev/${name}/releases/download/${version}/checksums.txt" && \
      verify "${name}.sha256" "$f" && install -m 0755 "$f" "/out/${name}" || exit 1; \
    done && \
    # oras
    f="oras_${ORAS_VERSION#v}_${TARGETOS}_${TARGETARCH}.tar.gz" && \
    curl -fsSLO "${gh}/oras-project/oras/releases/download/${ORAS_VERSION}/${f}" && \
    curl -fsSL -o oras.sha256 "${gh}/oras-project/oras/releases/download/${ORAS_VERSION}/oras_${ORAS_VERSION#v}_checksums.txt" && \
    verify oras.sha256 "$f" && tar -xzf "$f" -C /out oras && \
    # oc (only oc: kubectl comes from Alpine and stays current)
    f="openshift-client-${TARGETOS}.tar.gz" && \
    if [ "${TARGETARCH}" = "arm64" ]; then f="openshift-client-${TARGETOS}-arm64.tar.gz"; fi && \
    base="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}" && \
    curl -fsSLO "${base}/${f}" && curl -fsSL -o oc.sha256 "${base}/sha256sum.txt" && \
    verify oc.sha256 "$f" && tar -xzf "$f" -C /out oc && \
    chmod 0755 /out/* && \
    echo "${FLUX_VERSION}" > /out/flux-version && \
    echo "${YTT_VERSION}" > /out/ytt-version && \
    echo "${IMGPKG_VERSION}" > /out/imgpkg-version && \
    echo "${ORAS_VERSION}" > /out/oras-version && \
    echo "${OC_VERSION}" > /out/oc-version

# azure-cli in a venv; build dependencies (Rust, headers) stay in this stage
FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS python-builder

# hadolint ignore=DL3018
RUN apk add --no-cache python3 musl-dev python3-dev libffi-dev openssl-dev cargo make gcc

COPY requirements.txt /tmp/requirements.txt
# hadolint ignore=DL3013
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir --requirement /tmp/requirements.txt

FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

# OCI Labels
LABEL org.opencontainers.image.title="debugcontainer"
LABEL org.opencontainers.image.description="Debug container with networking, storage, performance and Kubernetes tools"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

# hadolint ignore=DL3018
RUN apk upgrade --no-cache && \
    apk add --no-cache \
      arping bash bash-completion bind-libs bind-tools ca-certificates coreutils \
      crane curl ethtool fio git hdparm htop inetutils-telnet ioping iozone iperf \
      iperf3 iproute2 ipset iptables jq kmod kubectl less lsof mariadb-client \
      mariadb-connector-c mc minio-client mtr multitail net-tools netcat-openbsd \
      nfs-utils ngrep nmap openssh openssh-client openssl p7zip parallel perl-utils \
      psmisc py3-pip python3 rsync screen socat speedtest-cli sslscan tcpdump tcptraceroute \
      tmux tree vim wget which yq

COPY --from=python-builder /opt/venv /opt/venv
COPY --from=downloader /out/flux /out/ytt /out/imgpkg /out/oras /out/oc /usr/local/bin/
# Tool versions for runtime inspection: /etc/<tool>-version
COPY --from=downloader /out/*-version /etc/
COPY --chmod=755 scripts/ /scripts/

RUN crane completion bash > /etc/bash_completion.d/crane && \
    oras completion bash > /etc/bash_completion.d/oras && \
    flux completion bash > /etc/bash_completion.d/flux && \
    mkdir -p /workdir && \
    addgroup -g 1000 abc && \
    adduser -G abc -u 1000 -D abc

ENV PATH="/opt/venv/bin:${PATH}" \
    PS1="\u@debugcontainer(\h):\w\\$ " \
    HOME="/workdir" \
    TERM="xterm" \
    TZ="Europe/Zurich"

WORKDIR /workdir

# Runs as root on purpose (documented exception): tcpdump, iptables, nmap,
# arping, hdparm and friends need it. Use `--user 1000` / runAsUser: 1000
# for everything else.
CMD ["sleep", "infinity"]
