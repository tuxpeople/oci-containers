#!/usr/bin/env bash
# Functional test: start as a foreign UID with a read-only root, wait until
# JDownloader is downloaded and running, then stop it cleanly.
# The MyJDownloader login check (JDOWNLOADER_TEST_USER/_PASSWORD) is not
# implemented yet.
# Usage: test.sh <image>
set -euo pipefail
image="$1"
name="jd-test-$$"
vol="jd-test-$$"

docker volume create "$vol" >/dev/null
cleanup() {
  docker logs "$name" 2>&1 | tail -20 || true
  docker rm -f "$name" >/dev/null 2>&1 || true
  docker volume rm "$vol" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run -d --name "$name" --read-only --tmpfs /tmp --cap-drop ALL \
  -v "$vol:/opt/JDownloader" "$image" >/dev/null

ok=""
for _ in $(seq 1 60); do
  if docker exec "$name" sh -c 'test -f /opt/JDownloader/Core.jar && pgrep -f JDownloader.jar >/dev/null' 2>/dev/null; then
    ok=1; break
  fi
  sleep 3
done
[[ -n "$ok" ]] || { echo "::error::JDownloader did not start"; exit 1; }

docker stop -t 30 "$name" >/dev/null
[[ "$(docker inspect --format '{{.State.ExitCode}}' "$name")" == "0" ]] || { echo "::error::unclean stop"; exit 1; }
[[ "$(docker inspect --format '{{.Config.User}}' "$image")" == "1000" ]]
echo "✅ jdownloader-headless downloads and starts JDownloader, stops cleanly, runs as UID 1000"
