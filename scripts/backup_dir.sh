#!/usr/bin/env bash
# backup_dir.sh - Timestamped tar.gz backup with checksum and retention.
# Usage: backup_dir.sh /var/www /backups 7
set -euo pipefail
SRC="${1:?source}"; DEST="${2:?dest}"; KEEP="${3:-7}"
mkdir -p "$DEST"
OUT="$DEST/$(basename "$SRC")-$(date +%F_%H%M).tar.gz"
tar -czf "$OUT" -C "$(dirname "$SRC")" "$(basename "$SRC")"
sha256sum "$OUT" > "$OUT.sha256"
ls -1t "$DEST"/*.tar.gz | tail -n +$((KEEP+1)) | xargs -r rm -f --
echo "Backup written: $OUT"
