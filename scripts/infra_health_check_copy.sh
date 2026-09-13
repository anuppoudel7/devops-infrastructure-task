#!/bin/bash

LOG_FILE="/var/log/infra_health.log"
APP_CONTAINER="devops_backend"
DISK_THRESHOLD=85

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log_warning() {
    local message="$1"
    echo "[$(timestamp)] [WARNING] $message" | tee -a "$LOG_FILE"
}

CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {
    print 100 - $8
}')

RAM_USAGE=$(free | awk '/Mem:/ {
    printf "%.2f", $3/$2 * 100
}')

DISK_USAGE=$(df / | awk 'NR==2 {
    gsub("%", "", $5);
    print $5
}')

echo "Infrastructure Health Check"
echo "Time: $(timestamp)"
echo "CPU Usage: ${CPU_USAGE}%"
echo "RAM Usage: ${RAM_USAGE}%"
echo "Root Disk Usage: ${DISK_USAGE}%"

if ! systemctl is-active --quiet docker; then
    log_warning "Docker service is not running."
else
    echo "Docker: RUNNING"
fi

if docker inspect -f '{{.State.Status}}' "$APP_CONTAINER" 2>/dev/null | grep -q '^running$'; then
    echo "Application Container: RUNNING"
else
    log_warning "Application container '$APP_CONTAINER' is stopped or unavailable."
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    log_warning "Root disk usage is ${DISK_USAGE}%, above ${DISK_THRESHOLD}%."
fi
