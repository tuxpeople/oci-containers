# s3-backup-restore

Backs up a folder to an S3 bucket on a schedule and restores it, built from [bloveless/docker-images](https://github.com/bloveless/docker-images/tree/main/s3-backup-restore) on a distroless static base. Typical use: a sidecar or CronJob next to an application that keeps its state in a volume.

## Usage

```bash
docker run --rm ghcr.io/tuxpeople/s3-backup-restore:latest -h
```

```
s3-backup-restore [options] backup (hourly|daily|weekly|monthly)
s3-backup-restore [options] restore
s3-backup-restore [options] cron        # default command
```

Configuration is read from environment variables (e.g. `S3_BUCKET`, credentials, the folder to back up, `RESTORE_FILE`). See the [upstream source](https://github.com/bloveless/docker-images/tree/main/s3-backup-restore) for the full list.

## Image

- Built from the upstream commit that last changed `s3-backup-restore/`, cross-compiled for amd64/arm64
- Distroless `static-debian13:nonroot`, no shell, runs as UID 65532
- Upstream has not changed since 2022; the version stays `git-60f5b0c` until it does, but the image is rebuilt with new base images
- Tags: `git-<sha>`, `latest`

## Testing

No Goss tests (no shell for dgoss). `test.sh` checks the help output and that `cron` refuses to start without configuration:

```bash
docker build --build-arg VERSION=$(./get-version.sh) -t s3-backup-restore:test .
./test.sh s3-backup-restore:test
```

## Links

- [Upstream](https://github.com/bloveless/docker-images/tree/main/s3-backup-restore)
- [GitHub Repository](https://github.com/tuxpeople/oci-containers)
- [Image Registry (GHCR)](https://ghcr.io/tuxpeople/s3-backup-restore)
- [Image Registry (Docker Hub)](https://hub.docker.com/r/tdeutsch/s3-backup-restore)
