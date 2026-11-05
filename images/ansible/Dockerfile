# Based on https://4sysops.com/archives/how-to-deploy-ansible-inside-a-docker-container/
FROM ubuntu:24.04

# OCI Labels
LABEL org.opencontainers.image.title="ansible"
LABEL org.opencontainers.image.description="Ansible automation container with Kerberos support"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

ENV DEBIAN_FRONTEND=noninteractive

COPY requirements.txt /

# Install Ansible and dependencies into a virtualenv: pip cannot replace
# Python packages that Ubuntu installed via apt (e.g. packaging on 26.04)
# DL3008: Pin versions - We rely on Ubuntu 24.04 LTS base image versioning
# DL3009: Clean apt cache - Done via rm -rf below
# hadolint ignore=DL3008,DL3009
RUN apt-get update && \
  apt-get install --no-install-suggests --no-install-recommends --yes \
    gcc \
    python3-dev \
    python3-venv \
    libkrb5-dev \
    krb5-user && \
  python3 -m venv /opt/venv && \
  /opt/venv/bin/pip install --disable-pip-version-check --no-cache-dir -r /requirements.txt && \
  rm -rf /var/lib/apt/lists/* && \
  useradd -ms /bin/bash ansible

ENV PATH="/opt/venv/bin:$PATH"

USER ansible
WORKDIR /home/ansible

# Keep container running for Goss tests and interactive use
CMD ["sleep", "infinity"]
