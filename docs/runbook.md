# Incident Runbook (quick triage)

| Alert | First checks | Typical fixes |
|---|---|---|
| High CPU | `scripts/top_processes.sh`, `journalctl -p err -n 50` | Restart runaway service, tune PHP-FPM `pm.max_children`, look for cron storms |
| High memory / swap | `free -h`, `ps --sort=-%mem`, `dmesg \| grep -i oom` | Tune MySQL buffers, add swap, fix leaks |
| Disk full | `du -xh / --max-depth=2 \| sort -rh \| head`, `df -i` | `scripts/cleanup_logs.sh`, rotate logs, move backups |
| Service down | `systemctl status X`, `journalctl -u X -n 100` | Fix config (`nginx -t`), restart, add watchdog |
| High load, low CPU | `iostat -x 1`, `vmstat 1` | I/O wait: find heavy writers with `iotop` |
