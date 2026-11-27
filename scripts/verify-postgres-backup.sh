#!/bin/bash

set -euo pipefail
umask 077

if [[ $(id -u) -ne 0 ]]; then
    echo "Error: Not running as root user." >&2
    exit 1
fi


if [[ $# -ne 1 ]];  then
    echo "Error: You must provide ONE backup file." >&2
    echo "Example usage: $0 /var/backups/petclinic/petclinic-backup-20040425092120.sql" >&2
    exit 1
fi


container_name=backup-test



if docker run --rm -d --name $container_name \
 -e POSTGRES_PASSWORD=backup -e POSTGRES_USER=petclinic -e POSTGRES_DB=backup postgres:18; then

    echo "Starting PostgreSQL container..." 
    
else 
    echo "Error: Failed to start Postgres Container." >&2
    exit 1
fi

trap 'sudo docker rm -f "$container_name" &>/dev/null' EXIT
 

if ! docker exec "$container_name" bash -c '

SECONDS=0
FAIL=10
until pg_isready -q -h 127.0.0.1; do
 if (( $SECONDS > $FAIL )); then 
     exit 1
 fi 
    sleep 1
done'; then
  echo "Error: PostgreSQL failed to become ready in time" >&2
  exit 1
fi


if docker exec -i "$container_name" sh -c '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 > /dev/null &&
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 \
 -c "SELECT id, first_name, last_name FROM public.owners ORDER BY id LIMIT 5;"' < "$1"; then

    echo "PostgreSQL restored successfully." 
else
    echo "Error: Restore or verification query failed." >&2
    exit 1
fi




