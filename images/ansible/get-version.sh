#!/usr/bin/env bash
# Extract Ansible version from requirements.txt
# Returns the semantic version number (e.g., "13.1.0")

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIREMENTS_FILE="${SCRIPT_DIR}/requirements.txt"

if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
  echo "ERROR: requirements.txt not found" >&2
  exit 1
fi

# Extract version from ansible==X.Y.Z line
version=$(grep "^ansible==" "$REQUIREMENTS_FILE" | cut -d'=' -f3)

if [[ -z "$version" ]]; then
  echo "ERROR: Could not extract Ansible version from requirements.txt" >&2
  exit 1
fi

echo "${version}"
