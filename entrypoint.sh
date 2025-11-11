#!/usr/bin/env bash
set -euo pipefail

# entrypoint.sh
# Ensure standard runtime dirs exist (when mounted from host they may be missing),
# then hand off to the upstream docker-entrypoint which prepares db if needed.

mkdir -p tmp tmp/cache tmp/pids tmp/sockets log storage

# Note: We do not attempt to chown here. For Windows host mounts use the
# scripts/fix-permissions.ps1 helper to make these directories writable.

exec /rails/bin/docker-entrypoint "$@"
