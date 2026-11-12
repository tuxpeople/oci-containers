# buildah_rootless - buildah for rootless image builds in a pod (e.g. OpenShift)
# From: https://github.com/containers/buildah/blob/main/docs/tutorials/05-openshift-rootless-build.md

# The tag is the image version (get-version.sh reads it), Renovate updates it
FROM quay.io/buildah/stable:v1.45.1@sha256:2807c70ecb10a9352e016eacaa2e1d5e8ab1ebe8c36313641727f87531f25b50

# OCI Labels
LABEL org.opencontainers.image.title="buildah_rootless"
LABEL org.opencontainers.image.description="buildah configured for rootless builds (chroot isolation, vfs storage)"
LABEL org.opencontainers.image.vendor="tuxpeople"
LABEL org.opencontainers.image.source="https://github.com/tuxpeople/oci-containers"

# Subordinate IDs for the build user (UID 1000), group-writable so that
# OpenShift's arbitrary UIDs can use them too
RUN touch /etc/subgid /etc/subuid \
 && chmod g=u /etc/subgid /etc/subuid /etc/passwd \
 && echo build:10000:65536 > /etc/subuid \
 && echo build:10000:65536 > /etc/subgid

# chroot: the default runc does not work rootless
# vfs: fuse-overlayfs does not work without /dev/fuse
# As environment variables they apply to every process, not only to
# interactive bash shells (.bashrc)
ENV BUILDAH_ISOLATION=chroot \
    STORAGE_DRIVER=vfs

USER 1000
WORKDIR /home/build

# Keep the container running for Goss tests and `oc rsh`/`kubectl exec`
CMD ["sleep", "infinity"]
