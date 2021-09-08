#!/bin/bash

# The original assignment requires to use imaginary SFTP and AWS cloud products 
# such as EC2, S3, and Redshift which hinder thorough testing.
# Hence, the rest of the script assumes Tasks to be running against PostgreSQL.

# Usage ./scripts/entrypoint.sh

set -eo pipefail

# Environmental variables
BASE_URL=https://info0.s3.us-east-2.amazonaws.com/assignment/engineering/data/
FILE_NAMES=(
    "master.csv"
    "timelog.csv"
    "title.csv"
)
WORKDIR=./work/ghr/

# Postgres credentials
source .env
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}
POSTGRES_DB=${POSTGRES_DB:-postgres}
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_USER=${POSTGRES_USER:-postgres}


echo "✅ [INFO]: Begin ETL"

# Task 1) SFTP ingestion
echo "⏳ Transferring data..."

for FILE_NAME in ${FILE_NAMES[*]};
do
    mkdir -p $WORKDIR
    curl -L ${BASE_URL%?}/$FILE_NAME -o ${WORKDIR%?}/$FILE_NAME
done

echo "✔ Data have been transferred."


# Task 2) SQL Ingestion
# Create tables
echo "⏳ Creating tables..."

echo $POSTGRES_PASSWORD $POSTGRES_DB $POSTGRES_HOST $POSTGRES_PORT $POSTGRES_USER

PGPASSWORD=$POSTGRES_PASSWORD psql \
    --dbname=$POSTGRES_DB \
    --file=./scripts/sql/create_tables.sql \
    --host=$POSTGRES_HOST \
    --port=$POSTGRES_PORT \
    --username=$POSTGRES_USER

echo "✔ Tables have been created."

# Copy tables from files
for FILE_PATH in ${WORKDIR%?}/*.csv;
do
    FILE_NAME=$(basename $FILE_PATH)
    TABLE_NAME=${FILE_NAME%.*}

    echo "⏳ Copying $TABLE_NAME from $FILE_NAME..."

    PGPASSWORD=$POSTGRES_PASSWORD psql \
        --command="\COPY $TABLE_NAME FROM $FILE_PATH WITH (FORMAT csv, NULL '\N', HEADER true, ENCODING 'WIN1251');" \
        --dbname=$POSTGRES_DB \
        --host=$POSTGRES_HOST \
        --port=$POSTGRES_PORT \
        --username=$POSTGRES_USER
  
    echo "✔ $TABLE_NAME has been copied from $FILE_NAME."
done

# Create a single table
echo "⏳ Creating a posting table..."

PGPASSWORD=$POSTGRES_PASSWORD psql \
    --dbname=$POSTGRES_DB \
    --file=./scripts/sql/create_posting.sql \
    --host=$POSTGRES_HOST \
    --port=$POSTGRES_PORT \
    --username=$POSTGRES_USER

echo "✔ The posting table has been created."

# Flush out files finally
rm -rf $(dirname $WORKDIR)


# Task 3) Data update
# This task is skipped: there is no means to replicate it given the sample files.
# However, the updating logic can be found at ./scripts/sql/update_posting.sql.


# Task 4) Data processing
# Create a reporting table
echo "⏳ Creating a reporting table..."

PGPASSWORD=$POSTGRES_PASSWORD psql \
    --dbname=$POSTGRES_DB \
    --file=./scripts/sql/create_reporting.sql \
    --host=$POSTGRES_HOST \
    --port=$POSTGRES_PORT \
    --username=$POSTGRES_USER

echo "✔ The reporting table has been created."

echo "🚩 [INFO]: ETL has been finished!"
