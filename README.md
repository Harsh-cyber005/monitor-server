### Monitoring Server

This is the repository for the Monitor server which is used to expose routes for the Monitor project. This was my first try to build a monitoring system like Prometheus and Grafana, even though I do not know how do they work. This project was built to just monitor my Virtual Machines over the cloud for several purposes. One of the purpose being able to make another project which deploys react and node.js applications on my VMs in a click.

#### Tech-Stack used:

- Node
- Typescript
- Sqlite
- pnpm (as the package manager)
- prisma (as the ORM)

#### Steps to start this Project on your machine

1. clone the repo into your machine
    ```bash
    git clone https://github.com/Harsh-cyber005/monitor-server.git
    ```

2. ensure you have Node installed in your machine
    ```bash
    node -v
    ```
    This project was built on __Node v24.12.0__

3. ensure you have pnpm installed in your machine
    ```bash
    npm install pnpm -g
    ```

4. move into the project directory
    ```bash
    cd monitor-server/
    ```

5. install dependencies
    ```bash
    pnpm install
    ```

6. you may need to approve several engines like prisma-engine, etc. approve all of them using:
    ```bash
    pnpm approve-builds
    ```

7. now make a .env file using the .env.example file as reference, by default it has all the non-secret values set

8. now migrate the prisma schema into the new dev.db database using:
    ```bash
    pnpm exec prisma migrate dev --name init
    ```

9. generate the prisma client
    ```bash
    pnpm exec prisma generate
    ```

10. (Optional) you can view your database live at [PORT-51212](http://localhost:51212/), if you do:
    ```bash
    pnpm exec prisma studio
    ```


#### Track your VM

1. make a new directory in you machine, /monitor (say)

2. make a new file metrics.sh inside this new directory and paste this into it:
    ```bash
    #!/bin/bash

    set -euo pipefail

    VM_ID_FILE="/var/lib/vm-monitor/vm-id"

    if [ ! -s "$VM_ID_FILE" ]; then
            echo "ERROR: VM ID file missing or empty at $VM_ID_FILE" >&2
            exit 1
    fi

    VM_ID=$(cat "$VM_ID_FILE")

    CPU_USED=$(top -bn1 | awk -F',' '/Cpu/ {print $4}' | awk '{print 100-$1}')

    read RAM_TOTAL RAM_USED <<< $(free -m | awk '/Mem:/ {print $2, $3}')

    read DISK_TOTAL DISK_USED <<< $(df -m --output=size,used / | tail -1)

    TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    HOSTNAME=$(hostname -I | awk '{print $1}')

    IP=$(curl -s -4 https://icanhazip.com | tr -d '\n')

    JSON=$(printf '{\n'
    printf '\t"vmId":"%s",\n' "$VM_ID"
    printf '\t"status":"%s",\n' "running"
    printf '\t"timestamp":"%s",\n' "$TS"
    printf '\t"ramUsedMB":%d,\n' "$RAM_USED"
    printf '\t"ramTotalMB":%d,\n' "$RAM_TOTAL"
    printf '\t"diskUsedMB":%d,\n' "$DISK_USED"
    printf '\t"diskTotalMB":%d,\n' "$DISK_TOTAL"
    printf '\t"cpuUsed":%.2f,\n' "$CPU_USED"
    printf '\t"hostname":"%s",\n' "$HOSTNAME"
    printf '\t"publicIp":"%s"\n' "$IP"
    printf '}\n')

    echo ${JSON}

    curl -sS --fail --connect-timeout 3 --max-time 5 -X POST -H "Content-Type: application/json" --data "$JSON" http://localhost:5000/monitor/vm-status > /dev/null
    ```

3. make another file named setup.sh inside the same directory and paste this code into it:

    ```bash
    #!/bin/bash
    set -euo pipefail

    VM_ID_FILE="/var/lib/vm-monitor/vm-id"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    METRICS_FILE=$SCRIPT_DIR/metrics.sh
    EMETRICS_FILE=$SCRIPT_DIR/emetrics.err

    echo "[setup] metrics.sh -> $METRICS_FILE"
    echo "[setup] metrics.err -> $EMETRICS_FILE"

    # ensure vm-id file exists and has the uuid
    if [[ ! -s "$VM_ID_FILE" ]]; then
            sudo mkdir -p /var/lib/vm-monitor
            sudo chmod 755 /var/lib/vm-monitor
            uuidgen | sudo tee "$VM_ID_FILE" > /dev/null
            sudo chmod 644 "$VM_ID_FILE"
            echo "[setup] Creating VM ID"
            cat "$VM_ID_FILE"
    else
            echo "[setup] VM ID already exists"
            cat "$VM_ID_FILE"
    fi

    # ensure metrics.sh file exists and is executable
    if [[ ! -f "$METRICS_FILE" ]]; then
            echo "ERROR: metrics.sh file not found at $METRICS_FILE" >&2
            exit 1
    else
            echo "metrics.sh file exists"
    fi

    sudo chmod +x "$METRICS_FILE"

    echo "[setup] metrics.sh is executable"
    echo "[setup] done"


    # setting up the cron
    read -rp "Run metrics every how many minutes? (1–60, default 1): " INTERVAL
    INTERVAL=${INTERVAL:-1}

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
    (crontab -l 2>/dev/null | grep -v -F "$METRICS_FILE" || true
        echo "$CRON_LINE"
    ) | crontab -
    echo "[setup] Done installing cron job -> $CRON_LINE"
    ```

4. give executable permission to setup.sh:
    ```bash
    sudo chmod +x setup.sh
    ```

5. Now run the setup.sh using:
    
    ```bash
    ./setup.sh
    ```

This sets up the VM to send metrics data to the central Monitor server.