#!/usr/bin/env bash
# Functional test: start as a foreign UID with a read-only root, wait until
# JDownloader is downloaded and running, then stop it cleanly.
# With JDOWNLOADER_TEST_USER/_PASSWORD also log in to MyJDownloader.
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

# MyJDownloader login, after the first container stopped (same volume, no
# second download); the secrets are empty in PRs from forks
if [[ -n "${JDOWNLOADER_TEST_USER:-}" && -n "${JDOWNLOADER_TEST_PASSWORD:-}" ]]; then
  login="${name}-login"
  docker run -d --name "$login" --read-only --tmpfs /tmp --cap-drop ALL \
    -v "$vol:/opt/JDownloader" -e MYJD_USER="$JDOWNLOADER_TEST_USER" \
    -e MYJD_PASSWORD="$JDOWNLOADER_TEST_PASSWORD" -e MYJD_DEVICE_NAME="ci-$$" "$image" >/dev/null
  sleep 90
  # TODO: replace this diagnostic output with a check once the log line is known
  docker logs "$login" 2>&1 | grep -i -E "myjdownloader|connect" | grep -v -i password | cut -c1-200 | sort -u | tail -40 || true
  docker exec "$login" sh -c 'jq "del(.email, .password)" /opt/JDownloader/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json' || true
  docker rm -f "$login" >/dev/null
else
  echo "No JDOWNLOADER_TEST_* credentials, skipping the MyJDownloader login test"
fi
echo "✅ jdownloader-headless downloads and starts JDownloader, stops cleanly, runs as UID 1000"
