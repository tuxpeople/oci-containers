#!/usr/bin/env bash
# Runtime test for the distroless image (no shell, so no Goss): start the
# server, send one message via UDP and one via TCP, expect both on stdout.
# The messages come from a busybox container in the server's network
# namespace, so no ports need to be published (UDP port forwarding is not
# reliable on every Docker host, e.g. Colima).
# Usage: test.sh <image>
set -euo pipefail
image="$1"
helper="busybox:1.38.0"

id=$(docker run -d --read-only --cap-drop ALL "$image")
trap 'docker logs "$id" || true; docker rm -f "$id" >/dev/null' EXIT

send() {
  docker run --rm --network "container:${id}" "$helper" sh -c "$1"
}

# Wait until the TCP listener accepts connections
for _ in $(seq 1 30); do
  send 'nc -z 127.0.0.1 5140' && break
  sleep 1
done

send 'echo "<14>1 2026-01-01T00:00:00Z host test - - - hello-udp" | nc -u -w1 127.0.0.1 5140'
send 'echo "<14>1 2026-01-01T00:00:00Z host test - - - hello-tcp" | nc -w1 127.0.0.1 5140'

for msg in hello-udp hello-tcp; do
  for _ in $(seq 1 10); do
    docker logs "$id" 2>&1 | grep -q "$msg" && break
    sleep 1
  done
  docker logs "$id" 2>&1 | grep -q "$msg" || { echo "::error::$msg not received"; exit 1; }
done

[[ "$(docker inspect --format '{{.Config.User}}' "$image")" == "65532" ]]
echo "✅ tinysyslog received UDP and TCP messages, runs as UID 65532"
