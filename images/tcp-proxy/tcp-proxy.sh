#!/bin/sh
# Relay TCP connections from LISTEN_PORT to TARGET_HOST:TARGET_PORT.
# Configuration via environment variables or arguments: tcp-proxy <host> <port>
set -eu

HOST="${TARGET_HOST:-${1:-}}"
PORT="${TARGET_PORT:-${2:-}}"
LISTEN_PORT="${LISTEN_PORT:-${PORT}}"

if [ -z "${HOST}" ] || [ -z "${PORT}" ]; then
    echo "usage: tcp-proxy <target host> <target port>" >&2
    echo "   or: TARGET_HOST=... TARGET_PORT=... [LISTEN_PORT=...] tcp-proxy" >&2
    exit 1
fi

echo "relay TCP/IP connections on :${LISTEN_PORT} to ${HOST}:${PORT}"
exec socat "TCP-LISTEN:${LISTEN_PORT},fork,reuseaddr" "TCP:${HOST}:${PORT}"
