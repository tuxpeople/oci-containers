# jdownloader-headless

[JDownloader 2](https://jdownloader.org/) without GUI, controlled via [MyJDownloader](https://my.jdownloader.org/). Works in Docker and in Kubernetes: JDownloader updates itself and restarts inside the container, so a pod is not recreated in an endless update loop.

> **Best effort, no support.** The image is maintained for the community, but there is no guarantee for fixes or answers to issues.

## Usage

```bash
docker run -d --restart=always --name jdownloader \
  -v /path/to/jdownloader:/opt/JDownloader \
  -v /path/to/downloads:/opt/JDownloader/Downloads \
  -e MYJD_USER=email@example.com -e MYJD_PASSWORD=secret -e MYJD_DEVICE_NAME=docker \
  ghcr.io/tuxpeople/jdownloader-headless:latest
```

### Docker Compose

```yaml
services:
  jdownloader:
    image: ghcr.io/tuxpeople/jdownloader-headless:latest   # or tdeutsch/jdownloader-headless
    restart: always
    user: "1000:1000"   # any UID that owns the volumes
    volumes:
      - ./jdownloader:/opt/JDownloader
      - ./downloads:/opt/JDownloader/Downloads
    environment:
      MYJD_USER: email@example.com
      MYJD_PASSWORD: secret
      MYJD_DEVICE_NAME: docker
```

| Variable | Description |
|---|---|
| `MYJD_USER`, `MYJD_PASSWORD` | MyJDownloader login (written to `cfg/` on every start) |
| `MYJD_DEVICE_NAME` | Device name shown in MyJDownloader |
| `VMARGS` | Additional JVM arguments, e.g. `-Xmx1g` |
| `UMASK` | umask for downloaded files, octal, e.g. `0002` |

### Volumes

| Path | Description |
|---|---|
| `/opt/JDownloader` | **Recommended.** JDownloader itself (downloaded on the first start), its updates, `cfg/` and `logs/`. Without this volume JDownloader is downloaded and updated again after every recreation of the container (`docker run --rm`, pod rescheduling) |
| `/opt/JDownloader/Downloads` | Downloads |
| `/opt/JDownloader/cfg` | Configuration only, if you don't mount `/opt/JDownloader` |

The volumes must be writable for the UID the container runs as (default 1000).

Debugging: create `jdownloader-block.txt` in the download folder, the container then starts without JDownloader and you can `docker exec` into it.

## Image

- Alpine with OpenJDK 21 (armv7: OpenJDK 8, the only Java Alpine ships for armv7), ffmpeg, fonts and sevenzipjbinding for archive extraction
- Platforms: `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- Runs as UID 1000 (any UID works), read-only root filesystem possible with `/opt/JDownloader` as a volume
- Also on Docker Hub as `tdeutsch/jdownloader-headless`
- Build versioning (Conventional Commits), continuing after `1.6.0`
- Tags: `X.Y.Z`, `X.Y`, `X`, `latest`

## Upgrade from 1.x

- **No longer runs as root.** Make the volumes writable for UID 1000 or set `--user`/`runAsUser` to the owner of your files.
- Mount `/opt/JDownloader` instead of only `cfg/` to keep JDownloader and its updates.
- Java 21 instead of OpenJDK 8 (except armv7).
- The `weekly` and `devel` tags are no longer updated; use `latest` or a version tag.

## History

Originally made by [Jay Moulin](https://github.com/jaymoulin/docker-jdownloader) (MIT, see `LICENSE`). Forked in 2020 as [tuxpeople/docker-jdownloader-headless](https://github.com/tuxpeople/docker-jdownloader-headless) to make it work in Kubernetes ([jaymoulin/docker-jdownloader#82](https://github.com/jaymoulin/docker-jdownloader/issues/82)), built here since 2026-11.
