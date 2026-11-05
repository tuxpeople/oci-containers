# buildah_rootless

[buildah](https://buildah.io/) prepared for rootless image builds inside a pod, e.g. on OpenShift, following the [upstream tutorial](https://github.com/containers/buildah/blob/main/docs/tutorials/05-openshift-rootless-build.md).

## Usage

```bash
kubectl run buildah --image=ghcr.io/tuxpeople/buildah_rootless:latest
kubectl exec -it buildah -- buildah bud -t example:dev .
```

The container keeps running (`sleep infinity`) so you can exec into it.

## Configuration

| Setting | Value | Why |
|---|---|---|
| `BUILDAH_ISOLATION` | `chroot` | runc does not work rootless |
| `STORAGE_DRIVER` | `vfs` | fuse-overlayfs needs `/dev/fuse` |
| `/etc/subuid`, `/etc/subgid` | `build:10000:65536` | subordinate IDs for the `build` user, group-writable for arbitrary UIDs |
| User | `build` (UID 1000) | |

## Image

- Based on `quay.io/buildah/stable` (Fedora), pinned by digest
- Image version = buildah version from the `FROM` tag (`1.43.5`, `1.43`, `1`, `latest`); Renovate updates the tag
- Previously the container ran `python3 -m http.server` just to keep running; it uses `sleep infinity` now

## Testing

Goss checks the build user, the subordinate IDs, the buildah binary and that the rootless settings apply to every process. An actual build is not tested: rootless buildah needs user namespaces, which Docker's default seccomp profile (and therefore CI) does not allow.

```bash
docker build -t buildah_rootless:test .
GOSS_FILE=goss.yaml dgoss run buildah_rootless:test
```

## Links

- [buildah](https://github.com/containers/buildah)
- [GitHub Repository](https://github.com/tuxpeople/oci-containers)
- [Image Registry (GHCR)](https://ghcr.io/tuxpeople/buildah_rootless)
- [Image Registry (Docker Hub)](https://hub.docker.com/r/tdeutsch/buildah_rootless)
