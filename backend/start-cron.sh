#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_JS_FILE_PATH="$CURRENT_DIR/dist/jobs/cleanup/cleanup.job.js"
CLEANUP_ERROR_LOG_PATH="$CURRENT_DIR/logs/cleanup_error.log"
CLEANUP_CONSOLE_LOG_PATH="$CURRENT_DIR/logs/cleanup_console.log"

if [[ ! -f "$CLEANUP_JS_FILE_PATH" ]]; then
  echo "Error: Cleanup job file not found at $CLEANUP_JS_FILE_PATH"
  exit 1
fi

if [[ ! -d "$CURRENT_DIR/logs" ]]; then
  mkdir -p "$CURRENT_DIR/logs"
fi

if [[ ! -f "$CLEANUP_ERROR_LOG_PATH" ]]; then
  touch "$CLEANUP_ERROR_LOG_PATH"
fi

if [[ ! -f "$CLEANUP_CONSOLE_LOG_PATH" ]]; then
  touch "$CLEANUP_CONSOLE_LOG_PATH"
fi

# running the cleanup job every day at midnight
INTERVAL_DAY=1

if [[ "$INTERVAL_DAY" -eq 1 ]]; then
    CRON_SCHEDULE="0 0 * * *"
else
    CRON_SCHEDULE="0 0 */$INTERVAL_DAY * *"
fi

NODE_PATH=$(which node)

CRON_CMD="$NODE_PATH $CLEANUP_JS_FILE_PATH 2>> $CLEANUP_ERROR_LOG_PATH 1>>$CLEANUP_CONSOLE_LOG_PATH"
CRON_LINE="$CRON_SCHEDULE $CRON_CMD"

echo "[setup] $CRON_LINE"

if crontab -l 2>/dev/null | grep -Fq "$CRON_LINE"; then
  echo "[setup] Exact cron already exists. Skipping."
  exit 0
fi

echo "[setup] Installing cron job (interval = $INTERVAL_DAY day(s))"
(crontab -l 2>/dev/null | grep -v -F "$CLEANUP_JS_FILE_PATH" || true
    echo "$CRON_LINE"
) | crontab -
echo "[setup] Done installing cron job -> $CRON_LINE"