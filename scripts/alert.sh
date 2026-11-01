#!/usr/bin/env bash
# alert.sh - Send an alert by email and/or Slack webhook. Usage: alert.sh "message"
set -uo pipefail
CONF="${CONF:-/etc/server-monitor/monitor.conf}"
[[ -f "$CONF" ]] || CONF="$(dirname "$0")/../config/monitor.conf"
source "$CONF"
MSG="${1:?message required}"

if [[ -n "${ALERT_EMAIL:-}" ]] && command -v mail >/dev/null; then
  echo "$MSG" | mail -s "[ALERT] $(hostname)" "$ALERT_EMAIL"
fi
if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
  curl -fsS -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"${MSG//\"/\\\"}\"}" "$SLACK_WEBHOOK_URL" >/dev/null
fi
