#!/bin/bash
set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
  echo "ERROR: Do not run this script with sudo" >&2
  exit 1
fi

echo "[setup] Requesting sudo access..."
sudo ls >> /dev/null

CRON_USER="$(id -un)"
SCRIPT_DIR="/var/lib/vm-monitor/scripts"
VM_ID_FILE="/var/lib/vm-monitor/vm-id"
VM_SECRET_FILE="/var/lib/vm-monitor/vm-secret"

METRICS_FILE=$SCRIPT_DIR/metrics.sh
EMETRICS_FILE=$SCRIPT_DIR/emetrics.err

echo "[setup] metrics.sh -> $METRICS_FILE"
echo "[setup] metrics.err -> $EMETRICS_FILE"

# ensure vm-id file exists and has the uuid
if [[ ! -s "$VM_ID_FILE" ]]; then
        echo "[setup] VM ID not found."
        INPUT_VM_ID="{{VM_ID}}"
        if [[ -z "$INPUT_VM_ID" ]]; then
                echo "ERROR: VM ID cannot be empty" >&2
                exit 1
        fi
        sudo mkdir -p /var/lib/vm-monitor
        sudo chmod 755 /var/lib/vm-monitor
        printf "%s\n" "$INPUT_VM_ID" | sudo tee "$VM_ID_FILE" > /dev/null
        sudo chmod 644 "$VM_ID_FILE"
        echo "[setup] Creating VM ID"
        cat "$VM_ID_FILE"
else
        echo "[setup] VM ID already exists"
        cat "$VM_ID_FILE"
fi

if [[ ! -s "$VM_SECRET_FILE" ]]; then
        echo "[setup] VM secret not found."
        INPUT_VM_SECRET="{{VM_SECRET}}"
        if [[ -z "$INPUT_VM_SECRET" ]]; then
                echo "ERROR: VM secret cannot be empty" >&2
                exit 1
        fi
        printf "%s\n" "$INPUT_VM_SECRET" | sudo tee "$VM_SECRET_FILE" > /dev/null
        sudo chown "$CRON_USER:$CRON_USER" "$VM_SECRET_FILE"
        sudo chmod 600 "$VM_SECRET_FILE"

        echo "[setup] VM secret created"
else
        echo "[setup] VM secret already exists"
fi

if [[ ! -d "$SCRIPT_DIR" ]]; then
        sudo mkdir -p "$SCRIPT_DIR"
        sudo chmod 755 "$SCRIPT_DIR"
fi

# ensure metrics.sh file exists and is executable
# fetch metrics.sh safely
curl --progress-bar \
  https://gist.githubusercontent.com/Harsh-cyber005/1b3131d0bdddd37968cf81270eecef46/raw/144ba679f578b04bf32569cbf3291e7401f9bffb/metrics-dummy.sh \
| sudo tee "$METRICS_FILE" > /dev/null

sudo chown "$CRON_USER:$CRON_USER" "$METRICS_FILE"
sudo chmod 755 "$METRICS_FILE"
echo "[setup] metrics.sh is present and executable"

sudo touch "$EMETRICS_FILE"
sudo chown "$CRON_USER:$CRON_USER" "$EMETRICS_FILE"
sudo chmod 644 "$EMETRICS_FILE"
echo "[setup] emetrics.err is present"

# setting up the cron
INTERVAL=1

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || (( INTERVAL < 1 || INTERVAL > 60 )); then
echo "ERROR: Interval must be a number between 1 and 60" >&2
exit 1
fi

if [[ "$INTERVAL" -eq 1 ]]; then
        CRON_SCHEDULE="* * * * *"
else
        CRON_SCHEDULE="*/$INTERVAL * * * *"
fi


CRON_CMD="/bin/bash $METRICS_FILE 1>/dev/null 2>>$EMETRICS_FILE"
CRON_LINE="$CRON_SCHEDULE $CRON_CMD"

echo "$CRON_LINE"

if crontab -l 2>/dev/null | grep -Fq "$CRON_LINE"; then
echo "[setup] Exact cron already exists. Skipping."
exit 0
fi

echo "[setup] Installing cron job (interval = $INTERVAL minute(s))"

(
  crontab -l 2>/dev/null | grep -v -F "$METRICS_FILE" || true
  echo "$CRON_LINE"
) | crontab -

echo "[setup] Done installing cron job -> $CRON_LINE"
