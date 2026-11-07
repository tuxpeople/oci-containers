#!/usr/bin/env bash
# Semaphore version from the FROM tag in the Dockerfile, e.g. "2.17.0"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
version=$(sed -n -E 's#^FROM semaphoreui/semaphore:v([0-9.]+)(@.*)?$#\1#p' "${SCRIPT_DIR}/Dockerfile")

if [[ -z "$version" ]]; then
  echo "ERROR: could not read the Semaphore version from the Dockerfile" >&2
  exit 1
fi
echo "$version"
