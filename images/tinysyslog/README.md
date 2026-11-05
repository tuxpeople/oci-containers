# tinysyslog

[tinysyslog](https://github.com/alexferl/tinysyslog) is a tiny syslog server (RFC 5424/3164) that writes incoming messages to stdout, so they end up in the container logs. Built from source on a distroless static base.

## Usage

```bash
docker run -d --name tinysyslog -p 5140:5140/tcp -p 5140:5140/udp \
  ghcr.io/tuxpeople/tinysyslog:latest

logger -n 127.0.0.1 -P 5140 -d "hello"   # UDP
docker logs tinysyslog
```

All upstream flags can be passed as arguments, e.g. `--socket-type udp`, `--filter regex --filter-regex '...'` or `--sinks filesystem --sink-filesystem-filename /data/syslog.log` (mount a writable volume to `/data`).

### Kubernetes

Listens on port 5140 (unprivileged), so it runs with `runAsNonRoot`, `readOnlyRootFilesystem: true` and all capabilities dropped. Expose TCP and UDP 5140 via a Service.

## Image

- Built from the upstream release tag with Go, cross-compiled for amd64/arm64
- Distroless `static-debian13:nonroot`, no shell, runs as UID 65532
- Version follows upstream: the nightly build picks up new releases (`get-version.sh`)
- Tags: `X.Y.Z`, `X.Y`, `X`, `latest`

## Testing

No Goss tests (no shell for dgoss). `test.sh` starts the server and sends one UDP and one TCP message from a busybox container in its network namespace:

```bash
docker build --build-arg VERSION=$(./get-version.sh) -t tinysyslog:test .
./test.sh tinysyslog:test
```

## Links

- [Upstream](https://github.com/alexferl/tinysyslog)
- [GitHub Repository](https://github.com/tuxpeople/oci-containers)
- [Image Registry (GHCR)](https://ghcr.io/tuxpeople/tinysyslog)
- [Image Registry (Docker Hub)](https://hub.docker.com/r/tdeutsch/tinysyslog)
