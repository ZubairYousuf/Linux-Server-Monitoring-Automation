#!/usr/bin/env bash
# cleanup_logs.sh - Free disk space safely: old rotated logs, apt/dnf cache, journal.
set -euo pipefail
DAYS="${1:-14}"
echo "Before:"; df -h /
find /var/log -type f \( -name '*.gz' -o -name '*.[0-9]' \) -mtime +"$DAYS" -print -delete
journalctl --vacuum-time="${DAYS}d" || true
command -v apt-get >/dev/null && apt-get clean
command -v dnf >/dev/null && dnf clean all
echo "After:"; df -h /
