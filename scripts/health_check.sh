#!/usr/bin/env bash
# health_check.sh - Collect CPU, memory, swap, disk, load and service status.
# Exits 0 (OK), 1 (WARNING) or 2 (CRITICAL) so it can be used by cron/Nagios-style tools.
set -uo pipefail

CONF="${CONF:-/etc/server-monitor/monitor.conf}"
[[ -f "$CONF" ]] || CONF="$(dirname "$0")/../config/monitor.conf"
# shellcheck disable=SC1090
source "$CONF"

LOG_FILE="${LOG_FILE:-/var/log/server-monitor/health.log}"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || LOG_FILE="/tmp/health.log"

status=0
alerts=()

log() { echo "$(date '+%F %T') [$1] $2" | tee -a "$LOG_FILE"; }
raise() { # level message
  local level=$1 msg=$2
  alerts+=("[$level] $msg")
  if [[ $level == CRITICAL ]]; then status=2
  elif [[ $level == WARNING && $status -lt 1 ]]; then status=1; fi
  log "$level" "$msg"
}
# check_pct NAME VALUE WARN CRIT
check_pct() {
  if (( $2 >= $4 )); then raise CRITICAL "$1 ${2}%"
  elif (( $2 >= $3 )); then raise WARNING "$1 ${2}%"; fi
}

# ---- CPU (busy share over a 1s sample) ----
read -r _ u1 n1 s1 i1 _ < /proc/stat; sleep 1; read -r _ u2 n2 s2 i2 _ < /proc/stat
busy=$(( (u2+n2+s2) - (u1+n1+s1) )); total=$(( (u2+n2+s2+i2) - (u1+n1+s1+i1) ))
cpu=$(( 100 * busy / (total==0 ? 1 : total) ))
check_pct "CPU usage" "$cpu" "$CPU_WARN" "$CPU_CRIT"

# ---- Memory & swap ----
mem_total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
mem_avail=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
mem_pct=$(( 100 * (mem_total - mem_avail) / mem_total ))
check_pct "Memory usage" "$mem_pct" "$MEM_WARN" "$MEM_CRIT"

swap_total=$(awk '/SwapTotal/{print $2}' /proc/meminfo)
swap_free=$(awk '/SwapFree/{print $2}' /proc/meminfo)
if (( swap_total > 0 )); then
  swap_pct=$(( 100 * (swap_total - swap_free) / swap_total ))
  (( swap_pct >= SWAP_WARN )) && raise WARNING "Swap usage ${swap_pct}%"
fi

# ---- Disk & inodes ----
while read -r _ _ _ avail pct mount; do
  p=${pct%\%}
  if (( p >= DISK_CRIT )); then raise CRITICAL "Disk $mount at ${p}% (${avail} free)"
  elif (( p >= DISK_WARN )); then raise WARNING "Disk $mount at ${p}% (${avail} free)"; fi
done < <(df -hP -x tmpfs -x devtmpfs -x overlay | tail -n +2)

while read -r _ _ _ _ ipct mount; do
  [[ $ipct == "-" ]] && continue
  p=${ipct%\%}; (( p >= INODE_WARN )) && raise WARNING "Inodes $mount at ${p}%"
done < <(df -iP -x tmpfs -x devtmpfs -x overlay | tail -n +2)

# ---- Load average vs cores ----
cores=$(nproc); load1=$(cut -d' ' -f1 /proc/loadavg)
if awk -v l="$load1" -v c="$cores" -v m="$LOAD_FACTOR" 'BEGIN{exit !(l > c*m)}'; then
  raise WARNING "Load ${load1} is high for ${cores} cores"
fi

# ---- Services (units that are not installed are skipped) ----
for svc in $SERVICES; do
  if systemctl cat "$svc.service" &>/dev/null && ! systemctl is-active --quiet "$svc"; then
    raise CRITICAL "Service $svc is not running"
  fi
done

# ---- Zombie processes ----
z=$(ps -eo stat | grep -c '^Z')
(( z > 0 )) && raise WARNING "$z zombie process(es)"

(( status == 0 )) && log OK "All checks passed (cpu=${cpu}% mem=${mem_pct}% load=${load1})"

if (( ${#alerts[@]} > 0 )) && [[ -x "$(dirname "$0")/alert.sh" ]]; then
  "$(dirname "$0")/alert.sh" "$(hostname) health: ${alerts[*]}" || true
fi
exit $status
