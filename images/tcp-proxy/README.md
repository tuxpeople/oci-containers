# tcp-proxy

Relays TCP connections from a local port to another host and port with [socat](http://www.dest-unreach.org/socat/). Useful to expose a service under a different port or to reach something outside the cluster through a Service.

## Usage

```bash
# Arguments: target host and port (listens on the same port)
docker run --rm -p 5432:5432 ghcr.io/tuxpeople/tcp-proxy:latest db.example.com 5432

# Or environment variables, with a different listen port
docker run --rm -p 8080:8080 \
  -e TARGET_HOST=example.com -e TARGET_PORT=80 -e LISTEN_PORT=8080 \
  ghcr.io/tuxpeople/tcp-proxy:latest
```

| Variable | Description |
|---|---|
| `TARGET_HOST` | Host to relay to (or first argument) |
| `TARGET_PORT` | Port to relay to (or second argument) |
| `LISTEN_PORT` | Local port, defaults to `TARGET_PORT` |

Runs as UID 1001: use a `LISTEN_PORT` above 1024 or grant `NET_BIND_SERVICE`.

## Image

- Alpine with socat and a small POSIX shell script
- Based on [hpello/tcp-proxy-docker](https://github.com/hpello/tcp-proxy-docker)
- Build versioning (Conventional Commits), continuing after `1.1.1`
- Tags: `X.Y.Z`, `X.Y`, `X`, `latest`

## Testing

`test.sh` starts an HTTP backend and the proxy in front of it and fetches a page through the proxy:

```bash
docker build -t tcp-proxy:test .
./test.sh tcp-proxy:test
```

## Links

- [GitHub Repository](https://github.com/tuxpeople/oci-containers)
- [Image Registry (GHCR)](https://ghcr.io/tuxpeople/tcp-proxy)
- [Image Registry (Docker Hub)](https://hub.docker.com/r/tdeutsch/tcp-proxy)
