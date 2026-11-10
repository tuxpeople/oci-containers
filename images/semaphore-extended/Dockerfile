# semaphore-extended - Semaphore UI with additional CLI tools for tasks
# To add a tool: download it in the tools stage and add it to `tools` in test.sh

FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS tools

ARG TARGETOS
ARG TARGETARCH

# renovate: datasource=github-releases depName=cli/cli
ARG GH_VERSION=v2.103.3

RUN apk add --no-cache curl

# Every binary is verified against the checksums its release publishes
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
WORKDIR /tmp/dl
RUN mkdir -p /out && \
    verify() { grep -E "[ *]$2\$" "$1" | sha256sum -c -; } && \
    # gh
    base="https://github.com/cli/cli/releases/download/${GH_VERSION}" && \
    name="gh_${GH_VERSION#v}_${TARGETOS}_${TARGETARCH}" && \
    curl -fsSLO "${base}/${name}.tar.gz" && \
    curl -fsSL -o gh.sha256 "${base}/gh_${GH_VERSION#v}_checksums.txt" && \
    verify gh.sha256 "${name}.tar.gz" && \
    tar -xzf "${name}.tar.gz" -C /out --strip-components=2 "${name}/bin/gh" && \
    chmod 0755 /out/*

# The tag is the image version (get-version.sh reads it), Renovate updates it
FROM semaphoreui/semaphore:v2.20.23@sha256:00e6733dbca9a2bddf77e048f34f9002027c8a6f549a8cde18d13101e84a19c3

# OCI Labels
LABEL org.opencontainers.image.title="semaphore-extended"
LABEL org.opencontainers.image.description="Semaphore UI for Ansible with additional CLI tools (gh), without Terraform and OpenTofu"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

COPY --from=tools /out/ /usr/local/bin/

# Upstream's Alpine packages are as old as its image. Terraform, OpenTofu and
# Terragrunt are not used here and hold most of the scanner findings.
USER 0
RUN apk upgrade --no-cache && \
    rm -f /usr/local/bin/terraform /usr/local/bin/tofu /usr/local/bin/terragrunt

# Upstream's user, entrypoint and command stay unchanged
USER 1001
