#!/usr/bin/env bash
# Latest imgpkg release, e.g. "0.49.0". GITHUB_TOKEN is set in CI.
set -euo pipefail

curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer ${GITHUB_TOKEN}"} \
  https://api.github.com/repos/carvel-dev/imgpkg/releases/latest \
  | jq -r '.tag_name | ltrimstr("v")'
