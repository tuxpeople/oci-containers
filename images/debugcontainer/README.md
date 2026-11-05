# debugcontainer

Swiss army knife for debugging containers and Kubernetes: one Alpine image with networking, storage, performance and cluster tools. Start it where you need to test or debug something.

## Usage

```bash
# Kubernetes: throwaway pod with a shell
kubectl run debug --rm -it --image=ghcr.io/tuxpeople/debugcontainer:latest -- bash

# Attach to a running pod (shares its network namespace)
kubectl debug -it <pod> --image=ghcr.io/tuxpeople/debugcontainer:latest -- bash

# Docker
docker run --rm -it ghcr.io/tuxpeople/debugcontainer:latest bash
```

Without a command the container just sleeps (`sleep infinity`), so you can `kubectl exec` into it.

## Included tools

| Area | Tools |
|---|---|
| Networking | `tcpdump`, `nmap`, `mtr`, `iperf`, `iperf3`, `netcat`, `socat`, `arping`, `ethtool`, `tcptraceroute`, `ngrep`, `dig`/`nslookup`, `sslscan`, `telnet`, `iproute2`, `iptables`, `ipset`, `net-tools`, `openssh` |
| Containers & Kubernetes | `kubectl`, `flux`, `crane`, `oras`, `ytt`, `imgpkg` |
| Clients | `mariadb`, `mc` (MinIO), `az` (Azure CLI), `git`, `curl`, `wget` |
| Storage & performance | `fio`, `hdparm`, `ioping`, `iozone`, `nfs-utils`, `rsync`, `speedtest-cli`, `/scripts/hdd-perf.sh` |
| General | `bash`, `jq`, `yq`, `vim`, `less`, `screen`, `tmux`, `htop`, `lsof`, `psmisc`, `tree`, `mc`, `p7zip`, `parallel`, `multitail`, `python3` |

Versions of the downloaded tools: `cat /etc/*-version`.

## Image

- Alpine 3.24, `amd64` and `arm64`
- **Runs as root on purpose**, the network and disk tools need it. For everything else use `--user 1000` / `runAsUser: 1000` (user `abc`).
- Downloaded binaries (flux, ytt, imgpkg, oras) are verified against the checksums of their releases; Renovate keeps them current
- Also on Docker Hub as `tdeutsch/debugcontainer`
- Build versioning (Conventional Commits), continuing after `3.6.0`
- Tags: `X.Y.Z`, `X.Y`, `X`, `latest`

## History

Built in [tuxpeople/docker-debugcontainer](https://github.com/tuxpeople/docker-debugcontainer) until 2026-11 (tags `vX.Y.Z`; `latest` stayed at 3.6.0 from 2025-10 while only `nightly` was rebuilt). Changes in 4.0.0:

- `latest` and the version tags get every update again
- Removed `odo` (discontinued by Red Hat) and `oc` (the amd64 build needs glibc and never ran on Alpine); `kubectl` now comes from Alpine, it did not run on amd64 before either
- Downloads verified with checksums, azure-cli built in a separate stage (no compilers in the image)
- The `nightly`, `devel` and `edge` tags are no longer updated; use `latest` or a version tag
