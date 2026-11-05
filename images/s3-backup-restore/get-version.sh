#!/usr/bin/env bash
# Version from the last upstream commit that touched s3-backup-restore/ in
# the bloveless/docker-images monorepo, e.g. "git-60f5b0c". Commits to the
# other images in that repository don't create a new version.
# GITHUB_TOKEN is set in CI.
set -euo pipefail

sha=$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer ${GITHUB_TOKEN}"} \
  "https://api.github.com/repos/bloveless/docker-images/commits?path=s3-backup-restore&per_page=1" \
  | jq -r '.[0].sha')
echo "git-${sha:0:7}"
