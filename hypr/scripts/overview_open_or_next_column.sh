#!/usr/bin/env sh
set -eu

log_file="${XDG_RUNTIME_DIR:-/tmp}/overview_open_or_next_column.log"
timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
state="$(qs ipc -c overview prop get overview openState 2>/dev/null | tail -n 1 || true)"

case "$state" in
    false|False|0|no|NO)
        printf '%s pid=%s state=%s action=open\n' "$timestamp" "$$" "${state:-<empty>}" >> "$log_file"
        qs ipc -c overview call overview open
        ;;
    *)
esac
