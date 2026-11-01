# Linux Server Monitoring Automation

Lightweight, dependency-free Bash toolkit to monitor Linux servers (Ubuntu / Debian / CentOS / RHEL): CPU, memory, swap, disk, inodes, load average, service status and zombie processes, with email/Slack alerting, log rotation and a systemd timer. Modelled on production support workflows in a 24/7 shift environment.

## Features
- `health_check.sh` - threshold-based checks with OK/WARNING/CRITICAL exit codes (0/1/2)
- `alert.sh` - email (`mail`) and Slack webhook notifications
- `top_processes.sh` - triage snapshot of top CPU/memory/disk consumers
- `cleanup_logs.sh` - safe disk-space recovery (old logs, journal, package cache)
- `service_watchdog.sh` - auto-restart failed services
- `backup_dir.sh` - timestamped backups with checksum and retention
- systemd timer (every 5 min), logrotate config, incident runbook

## Install
```bash
git clone https://github.com/ZubairYousuf/Linux-Server-Monitoring-Automation.git
cd Linux-Server-Monitoring-Automation
sudo ./scripts/install.sh
sudo nano /etc/server-monitor/monitor.conf   # thresholds, services, Slack/email
```

## Usage
```bash
sudo /opt/server-monitor/health_check.sh; echo "exit=$?"
systemctl list-timers health-check.timer
tail -f /var/log/server-monitor/health.log
/opt/server-monitor/backup_dir.sh /var/www /backups 7
```

## Sample output
```
2026-11-01 10:05:01 [WARNING] Disk / at 83% (8.1G free)
2026-11-01 10:05:01 [CRITICAL] Service nginx is not running
```

## Skills demonstrated
Bash scripting, /proc parsing, systemd timers, logrotate, alerting, incident response, capacity monitoring.

## License
MIT
