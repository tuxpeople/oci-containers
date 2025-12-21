# Based on https://4sysops.com/archives/how-to-deploy-ansible-inside-a-docker-container/
FROM ubuntu:24.04

# OCI Labels
LABEL org.opencontainers.image.title="ansible"
LABEL org.opencontainers.image.description="Ansible automation container with Kerberos support"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

ENV DEBIAN_FRONTEND=noninteractive

COPY requirements.txt /

# Install Ansible and dependencies
# DL3008: Pin versions - We rely on Ubuntu 24.04 LTS base image versioning
# DL3009: Clean apt cache - Done via rm -rf below
# hadolint ignore=DL3008,DL3009
RUN apt-get update && \
  apt-get install --no-install-suggests --no-install-recommends --yes \
    gcc \
    python3-dev \
    libkrb5-dev \
    python3-pip \
    krb5-user && \
  pip3 install --upgrade --disable-pip-version-check --no-cache-dir --break-system-packages -r /requirements.txt && \
  rm -rf /var/lib/apt/lists/* && \
  useradd -ms /bin/bash ansible

USER ansible
WORKDIR /home/ansible

# Keep container running for Goss tests and interactive use
CMD ["sleep", "infinity"]
