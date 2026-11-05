# busycurl

busybox 1.38 (musl) with a fully static [curl](https://curl.se/) (OpenSSL, HTTP/2, SFTP/SCP via libssh2). Handy as a small debug or init container.

## Usage

```bash
docker run --rm ghcr.io/tuxpeople/busycurl:latest curl -fsS https://example.com
docker run --rm -it ghcr.io/tuxpeople/busycurl:latest sh
```

## Image

- curl is built from the signed upstream release (GPG-verified) and linked statically
- Image version = curl version (`8.23.0`, `8.23`, `8`, `latest`); the busybox version is pinned in the Dockerfile and updated by Renovate
- Runs as `nobody` (UID 65534), `CMD ["sleep", "infinity"]`
- The nightly build picks up new curl releases (`get-version.sh`)

Before the move to oci-containers the tags were `<busybox>-<curl>` (e.g. `1.38.0-musl-8.23.0`), and those images actually contained curl 8.11.0. Use the new tags.

## Testing

Goss checks the curl binary against the version the image was built for (`CURL_VERSION`), HTTPS with the bundled CA certificates and the UID. `build.sh` already fails if curl is not fully static.

```bash
docker build --build-arg VERSION=$(./get-version.sh) -t busycurl:test .
GOSS_FILE=goss.yaml dgoss run busycurl:test
```

## Links

- [curl](https://curl.se/)
- [GitHub Repository](https://github.com/tuxpeople/oci-containers)
- [Image Registry (GHCR)](https://ghcr.io/tuxpeople/busycurl)
- [Image Registry (Docker Hub)](https://hub.docker.com/r/tdeutsch/busycurl)
