#!/usr/bin/env bash
# service_watchdog.sh - Restart failed services and log it. Usage: service_watchdog.sh nginx mysql
for svc in "$@"; do
  if ! systemctl is-active --quiet "$svc"; then
    logger -t watchdog "$svc down, restarting"
    if systemctl restart "$svc"; then logger -t watchdog "$svc restarted"; else logger -t watchdog "$svc restart FAILED"; fi
  fi
done
