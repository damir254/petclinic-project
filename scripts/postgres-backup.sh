#!/bin/bash

set -euo pipefail
umask 077

if [[ $(id -u) -ne 0 ]]; then
    echo "Error: Not running as root user."
    exit 1
fi

if  docker compose version &>/dev/null; then
    COMPOSE="docker compose"

elif command -v docker-compose &>/dev/null; then
    COMPOSE="docker-compose"
else
    echo "Error: Docker Compose is not installed." >&2
    exit 1
fi


backup_dir="/var/backups/petclinic"
backup_name="petclinic-backup-$(date -u +%Y%m%d%H%M%S).sql"

mkdir -p "${backup_dir}"
if $COMPOSE -f /opt/petclinic/compose.yml exec -T petclinic-db \
 sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB"' > "${backup_dir}/${backup_name}"; then
    

    echo "Backup Successful." 
    echo "Backup file is located at ${backup_dir}/${backup_name}"
else
    echo "Error: Backup Failed." >&2
    echo "Deleting corrupted backup file..." >&2
    rm -f -- "${backup_dir}/${backup_name}"
    exit 1
fi