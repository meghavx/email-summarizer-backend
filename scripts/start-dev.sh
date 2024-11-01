#!/bin/bash

docker stop email_summarizer_db

DBNAME='poc'
DBUSERNAME='ruchita'
DB_PASSWORD='qwerty'

echo "Starting PostgreSQL container..."
docker run \
    --name email_summarizer_db \
    -e POSTGRES_PASSWORD=$DB_PASSWORD \
    -e POSTGRES_USER=$DBUSERNAME \
    -e POSTGRES_DB=$DBNAME \
    -p 5432:5432 \
    --rm -d \
    postgres:17.0-alpine3.20

echo "Waiting for PostgreSQL to start..."
while ! docker exec -it email_summarizer_db psql -U $DBUSERNAME -d $DBNAME  -c "\l"; 
    do sleep 4; 
    done

echo "Inserting data into database..."

# POPULATED DATABASE
# docker cp ./scripts/schema.sql email_summarizer_db:/
# docker exec -it email_summarizer_db psql -U $DBUSERNAME -d $DBNAME -c "\i schema.sql"

# NO RECORDS DATABASE
docker cp ./scripts/schema_clean.sql email_summarizer_db:/
docker exec -it email_summarizer_db psql -U $DBUSERNAME -d $DBNAME -c "\i schema_clean.sql"

python3 ./scripts/insert_doc.py

echo "Running Python script..."
python3 run.py
