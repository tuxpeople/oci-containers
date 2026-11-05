#!/usr/bin/env bash
# Runtime test for the distroless image (no shell, so no Goss).
# Usage: test.sh <image>
set -euo pipefail
image="$1"

out=$(docker run --rm "$image" version)
echo "$out"
grep -q "imgpkg version" <<< "$out"

# Runs as nonroot
[[ "$(docker inspect --format '{{.Config.User}}' "$image")" == "65532" ]]
echo "✅ imgpkg runs and the image uses UID 65532"
