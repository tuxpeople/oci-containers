#!/usr/bin/env bash
# Runtime test for the distroless image (no shell, so no Goss).
# Usage: test.sh <image>
set -euo pipefail
image="$1"

# Help lists the commands
docker run --rm "$image" -h | tee /dev/stderr | grep -q "s3-backup-restore \[options\] cron"

# Without configuration the cron command refuses to start
out=$(docker run --rm "$image" cron 2>&1 || true)
echo "$out"
grep -q 'required environment variable \\"S3_BUCKET\\"' <<< "$out"

[[ "$(docker inspect --format '{{.Config.User}}' "$image")" == "65532" ]]
echo "✅ s3-backup-restore runs, checks its configuration, runs as UID 65532"
