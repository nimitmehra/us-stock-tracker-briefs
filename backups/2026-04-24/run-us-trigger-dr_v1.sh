#!/bin/bash
# US Stock Tracker — daily /trigger-dr queue drainer
# Cron: 4:30 AM IST Tue-Sat = 7:00 PM ET EDT Mon-Fri (2 hrs after market-brief fires)
# Picks up anything market-brief queued and drains up to 10 full DRs (v1.3 caps)

CLAUDE="/Users/nimitmehra/.local/bin/claude"
DIR="/Users/nimitmehra/Manus/US-Stock-Tracker"
FLAGS="--dangerously-skip-permissions"
DATE=$(date +%Y-%m-%d)
LOG="$DIR/logs/cron-trigger-dr-$DATE.log"

cd "$DIR" || exit 1
mkdir -p logs

{
  echo "=== /trigger-dr started at $(date) ==="
  caffeinate -s -i "$CLAUDE" -p '/trigger-dr' $FLAGS
  echo "=== /trigger-dr completed at $(date) ==="
} >> "$LOG" 2>&1
