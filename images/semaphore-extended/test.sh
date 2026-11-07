#!/usr/bin/env bash
# Functional test: start the server with a local BoltDB, then check that it
# answers and that every added tool runs as the runtime user.
# Usage: test.sh <image>
set -euo pipefail
image="$1"
name="semaphore-extended-test-$$"
# Added tools, each must support --version
tools=(gh)

cleanup() {
  docker logs "$name" 2>&1 | tail -n 20 || true
  docker rm -f "$name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run -d --name "$name" --cap-drop ALL \
  -e SEMAPHORE_DB_DIALECT=bolt \
  -e SEMAPHORE_ADMIN=admin -e SEMAPHORE_ADMIN_PASSWORD=test-only \
  -e SEMAPHORE_ADMIN_NAME=Admin -e SEMAPHORE_ADMIN_EMAIL=admin@example.com \
  "$image" >/dev/null

out=""
for _ in $(seq 1 30); do
  out=$(docker exec "$name" curl -fsS http://localhost:3000/api/ping 2>/dev/null || true)
  [[ "$out" == "pong" ]] && break
  sleep 1
done
[[ "$out" == "pong" ]] || { echo "::error::server does not answer on /api/ping"; exit 1; }
echo "✅ server answers"

[[ "$(docker exec "$name" id -u)" == "1001" ]] || { echo "::error::not running as UID 1001"; exit 1; }
echo "✅ runs as UID 1001"

for tool in "${tools[@]}"; do
  docker exec "$name" "$tool" --version | head -n 1
done
echo "✅ all tools run"
