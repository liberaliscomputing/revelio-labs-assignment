#!/bin/bash

set -eo pipefail

cmd="$@"

until PGPASSWORD=$POSTGRES_PASSWORD psql \
    --command="\q" \
    --dbname=$POSTGRES_DB \
    --host=$POSTGRES_HOST \
    --port=$POSTGRES_PORT \
    --username=$POSTGRES_USER
do
    echo "⏳ PostgreSQL is unavailable - sleeping"
    sleep 1
done

echo "✅ PostgreSQL is up - executing command"
exec $cmd
