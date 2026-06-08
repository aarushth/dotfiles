#!/usr/bin/env bash

# Check if Firefox is already running
if pgrep -x firefox >/dev/null; then
    exit 0
fi

# Launch Firefox if not already open
firefox &
