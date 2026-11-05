#!/usr/bin/env bash
# Functional test: start a small HTTP backend and the proxy in front of it,
# then fetch a page through the proxy.
# Usage: test.sh <image>
set -euo pipefail
image="$1"
helper="busybox:1.38.0"
net="tcp-proxy-test-$$"

docker network create "$net" >/dev/null
cleanup() {
  docker logs "proxy-$$" 2>&1 || true
  docker rm -f "backend-$$" "proxy-$$" >/dev/null 2>&1 || true
  docker network rm "$net" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run -d --name "backend-$$" --network "$net" --network-alias backend "$helper" \
  sh -c 'mkdir -p /www && echo hello-through-proxy > /www/index.html && httpd -f -p 8080 -h /www' >/dev/null
docker run -d --name "proxy-$$" --network "$net" --network-alias proxy --read-only --cap-drop ALL \
  -e TARGET_HOST=backend -e TARGET_PORT=8080 -e LISTEN_PORT=9000 "$image" >/dev/null

out=""
for _ in $(seq 1 20); do
  out=$(docker run --rm --network "$net" "$helper" wget -qO- http://proxy:9000/ 2>/dev/null || true)
  [[ "$out" == "hello-through-proxy" ]] && break
  sleep 1
done
[[ "$out" == "hello-through-proxy" ]] || { echo "::error::no response through the proxy"; exit 1; }

# Without a target it refuses to start
if docker run --rm "$image" >/dev/null 2>&1; then
  echo "::error::started without target"; exit 1
fi

[[ "$(docker inspect --format '{{.Config.User}}' "$image")" == "1001" ]]
echo "✅ tcp-proxy relays TCP, refuses to start without target, runs as UID 1001"
