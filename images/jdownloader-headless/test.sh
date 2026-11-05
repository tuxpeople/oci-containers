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
  # JDownloader logs the MyJDownloader requests to its own log files: a 200
  # response means logged in, an exception (SRC: MYJD) names the reason.
  # Only the exception name is printed, the log contains the e-mail address.
  # shellcheck disable=SC2016 # runs in the container
  check='log() { find /opt/JDownloader/logs -name "org.jdownloader.api.myjdownloader.MyJDownloaderController.log.*" ! -name "*.lck" -exec grep -h "$@" {} +; }
    log -o -E "[A-Za-z]+Exception\(SRC: MYJD\)" | sort -u | grep . && exit 1
    log -E "^HTTP/1.1 200" | grep -q . && exit 0
    exit 2'
  result=2
  for _ in $(seq 1 60); do
    result=0
    docker exec "$login" sh -c "$check" || result=$?
    [[ "$result" -ne 2 ]] && break
    sleep 5
  done
  case "$result" in
    0) echo "MyJDownloader login OK" ;;
    1) echo "::error::MyJDownloader login failed (exception above)"; exit 1 ;;
    *) echo "::error::no MyJDownloader response within 5 minutes"; exit 1 ;;
  esac
  docker rm -f "$login" >/dev/null
else
  echo "No JDOWNLOADER_TEST_* credentials, skipping the MyJDownloader login test"
fi
echo "✅ jdownloader-headless downloads and starts JDownloader, stops cleanly, runs as UID 1000${login:+, logs in to MyJDownloader}"
