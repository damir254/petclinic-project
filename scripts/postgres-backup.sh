#!/bin/bash

set -euo pipefail
umask 077

if [[ $(id -u) -ne 0 ]]; then
    echo "Error: Not running as root user."
    exit 1
fi

backup_dir="/var/backups/petclinic"
backup_name="petclinic-backup-$(date -u +%Y%m%d%H%M%S).sql"

mkdir -p "${backup_dir}"
if docker compose -f /opt/petclinic/compose.yml exec -T petclinic-db \
 sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB"' > "${backup_dir}/${backup_name}"; then
    

    echo "Backup Successful." 
    echo "Backup file is located at ${backup_dir}/${backup_name}"
else
    echo "Error: Backup Failed."
    echo "Deleting corrupted backup file..."
    rm -f -- "${backup_dir}/${backup_name}"
    exit 1
fi