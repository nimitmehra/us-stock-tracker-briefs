#!/bin/bash
# US Stock Tracker — daily /market-brief orchestrator
# Cron: 2:30 AM IST Tue-Sat = 5:00 PM ET EDT Mon-Fri (1 hr post-close)
# Mirrors /Users/nimitmehra/Documents/Manus/hive-mind/scripts/run-brief.sh

CLAUDE="/Users/nimitmehra/.local/bin/claude"
DIR="/Users/nimitmehra/Documents/Manus/US-Stock-Tracker"
FLAGS="--dangerously-skip-permissions"
DATE=$(date +%Y-%m-%d)
LOG="$DIR/logs/cron-market-brief-$DATE.log"

cd "$DIR" || exit 1
mkdir -p logs

{
  echo "=== /market-brief started at $(date) ==="
  caffeinate -s -i "$CLAUDE" -p '/market-brief' $FLAGS
  echo "=== /market-brief completed at $(date) ==="
} >> "$LOG" 2>&1
