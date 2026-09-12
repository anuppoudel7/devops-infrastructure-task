#!/bin/bash

BACKUP_DIR="/var/backups/db"
CONTAINER="devops_db"
DATABASE="devopsdb"
USER="devops"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "Creating PostgreSQL backup..."

docker exec "$CONTAINER" \
    pg_dump -U "$USER" "$DATABASE" \
    | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup successful:"
    echo "$BACKUP_FILE"
else
    echo "Backup failed."
    rm -f "$BACKUP_FILE"
    exit 1
fi
