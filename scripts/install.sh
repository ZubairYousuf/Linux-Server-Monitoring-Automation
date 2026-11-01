#!/usr/bin/env bash
# install.sh - Install scripts, config, systemd timer and logrotate rule (run as root).
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run as root"; exit 1; }
SRC="$(cd "$(dirname "$0")/.." && pwd)"
install -d /opt/server-monitor /etc/server-monitor /var/log/server-monitor
install -m 0755 "$SRC"/scripts/*.sh /opt/server-monitor/
[[ -f /etc/server-monitor/monitor.conf ]] || install -m 0640 "$SRC/config/monitor.conf" /etc/server-monitor/monitor.conf
install -m 0644 "$SRC"/systemd/*.service "$SRC"/systemd/*.timer /etc/systemd/system/
install -m 0644 "$SRC/logrotate/server-monitor" /etc/logrotate.d/server-monitor
systemctl daemon-reload
systemctl enable --now health-check.timer
echo "Installed. Check: systemctl list-timers health-check.timer"
