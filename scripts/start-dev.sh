#!/bin/bash

docker stop email_summarizer_db

# Define database connection parameters
DBNAME='poc'
DBUSERNAME='ruchita'
DB_PASSWORD='qwerty'

# Start the PostgreSQL container
echo "Starting PostgreSQL container..."
docker run \
                --name email_summarizer_db \
                -e POSTGRES_PASSWORD=$DB_PASSWORD \
                -e POSTGRES_USER=$DBUSERNAME \
                -e POSTGRES_DB=$DBNAME \
                -p 5432:5432 \
                --rm -d \
                postgres:17.0-alpine3.20

# Wait for the container to be available
echo "Waiting for PostgreSQL to start..."
while ! docker exec -it email_summarizer_db psql -U $DBUSERNAME -d $DBNAME  -c "\l"; do sleep 4; done

# Insert data from schema.sql
echo "Inserting data into database..."
docker cp ./scripts/schema.sql email_summarizer_db:/
docker exec -it email_summarizer_db psql -U $DBUSERNAME -d $DBNAME -c "\i schema.sql"

python3 ./scripts/insert_doc.py

# Run the Python script
echo "Running Python script..."
python3 run.py
