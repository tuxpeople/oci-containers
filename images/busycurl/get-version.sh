#!/usr/bin/env bash
# Latest curl release, e.g. "8.23.0". This is the image version; the
# busybox version is pinned in the Dockerfile. GITHUB_TOKEN is set in CI.
set -euo pipefail

curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer ${GITHUB_TOKEN}"} \
  https://api.github.com/repos/curl/curl/releases/latest \
  | jq -r '.name'
