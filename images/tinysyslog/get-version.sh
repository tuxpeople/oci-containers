#!/usr/bin/env bash
# Latest tinysyslog release, e.g. "3.0.0". GITHUB_TOKEN is set in CI.
set -euo pipefail

curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer ${GITHUB_TOKEN}"} \
  https://api.github.com/repos/alexferl/tinysyslog/releases/latest \
  | jq -r '.tag_name | ltrimstr("v")'
