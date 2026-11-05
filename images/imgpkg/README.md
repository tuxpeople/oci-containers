# imgpkg

[Carvel imgpkg](https://carvel.dev/imgpkg/) CLI to store application configuration (Kubernetes manifests, Helm charts, …) as OCI images, on a distroless static base.

## Usage

```bash
docker run --rm ghcr.io/tuxpeople/imgpkg:latest version

# Pull a bundle into the current directory
docker run --rm -v "$PWD:/work" -w /work ghcr.io/tuxpeople/imgpkg:latest \
  pull -b ghcr.io/example/bundle:1.0.0 -o /work/bundle
```

Credentials for private registries can be passed as environment variables (`IMGPKG_REGISTRY_HOSTNAME`, `IMGPKG_REGISTRY_USERNAME`, `IMGPKG_REGISTRY_PASSWORD`) or by mounting a Docker config to `/home/nonroot/.docker/config.json`.

## Image

- Distroless `static-debian13:nonroot`, no shell, runs as UID 65532
- The binary is downloaded from the upstream release and verified against its `checksums.txt`
- Version follows upstream: the nightly build picks up new imgpkg releases (`get-version.sh`)
- Tags: `X.Y.Z`, `X.Y`, `X`, `latest`

## Testing

No Goss tests: the distroless image has no shell for dgoss. `test.sh` runs the binary from outside instead.

```bash
docker build --build-arg VERSION=$(./get-version.sh) -t imgpkg:test .
./test.sh imgpkg:test
```

## Links

- [Upstream](https://github.com/carvel-dev/imgpkg)
- [GitHub Repository](https://github.com/tuxpeople/oci-containers)
- [Image Registry (GHCR)](https://ghcr.io/tuxpeople/imgpkg)
- [Image Registry (Docker Hub)](https://hub.docker.com/r/tdeutsch/imgpkg)
