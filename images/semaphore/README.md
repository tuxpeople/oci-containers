# semaphore

[Semaphore UI](https://semaphoreui.com/) with additional CLI tools for tasks. Everything else is the upstream image `semaphoreui/semaphore`: same entrypoint, user (UID 1001) and configuration.

| Added tool | Purpose |
|---|---|
| [`gh`](https://cli.github.com/) | GitHub CLI |

## Usage

Replace the upstream image, nothing else changes:

```yaml
services:
  semaphore:
    image: ghcr.io/tuxpeople/semaphore:2.17.0
```

Upstream uses a `v` prefix (`v2.17.0`), these tags do not.

`gh` authenticates with the environment variable `GH_TOKEN`. Set it per task via a variable group in Semaphore, not on the container, so that only tasks that need it can read it.

## Image

- Based on `semaphoreui/semaphore`, Alpine packages upgraded during the build
- Tools are downloaded from their upstream release and verified against the published checksums
- Version follows upstream: it comes from the `FROM` tag (`get-version.sh`), Renovate updates it
- Tags: `X.Y.Z`, `X.Y`, `X`, `latest`. Pin a full version: Semaphore migrates its database on upgrades
- ⚠️ The tag does not change when only a tool or a package changes: `2.17.0` is rebuilt in place. Pin the digest if that matters
- Platforms: `linux/amd64`, `linux/arm64`

## Known findings

Trivy reports findings in the binaries that upstream ships (`semaphore`, `terraform`, `terragrunt`, `tofu`) and in its Ansible virtualenv. They can only be fixed upstream.

## Adding a tool

1. Download and verify it in the `tools` stage of the `Dockerfile`, with a `# renovate:` annotation. Everything in `/out` ends up in `/usr/local/bin`
2. Add it to `tools` in `test.sh`
3. Add it to the table above and to the image description

## Testing

No Goss tests: the server does not start without configuration, and dgoss cannot pass any. `test.sh` starts it with a local BoltDB instead.

```bash
docker build -t semaphore:test .
./test.sh semaphore:test
```
