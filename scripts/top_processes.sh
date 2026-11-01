#!/usr/bin/env bash
# top_processes.sh - Snapshot of top CPU and memory consumers for incident triage.
N="${1:-10}"
echo "=== Top $N by CPU ==="; ps -eo pid,user,%cpu,%mem,etime,comm --sort=-%cpu | head -n $((N+1))
echo; echo "=== Top $N by MEM ==="; ps -eo pid,user,%cpu,%mem,etime,comm --sort=-%mem | head -n $((N+1))
echo; echo "=== Top disk consumers in /var ==="; du -xh /var --max-depth=2 2>/dev/null | sort -rh | head -n "$N"
