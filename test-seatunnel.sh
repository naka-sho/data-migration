#!/bin/bash
# Make the script executable with: chmod +x test-seatunnel.sh

# Exit on error
set -e

echo "Starting containers..."
make up

echo "Waiting for containers to start..."
sleep 10

echo "Installing Embulk gems..."
docker exec -it embulk bash -c "
embulk gem install embulk -v 0.11.5
embulk gem install msgpack
embulk gem install bundler
embulk gem install liquid
embulk gem install embulk-input-randomj
embulk gem install embulk-output-postgresql
embulk gem install embulk-output-kafka
"

echo "Running Embulk to load data into Kafka..."
docker exec -it embulk bash -c "embulk run kafka.yml"

echo "Waiting for data to be processed by Kafka..."
sleep 5

echo "Running SeaTunnel to process Kafka messages and insert into PostgreSQL..."
docker exec -it seatunnel bash -c "seatunnel --config /work/seatunnel-config.conf --master local"

echo "Querying PostgreSQL to verify results in your_table_name..."
docker exec -it postgres psql -U postgres -d postgres -c "SELECT * FROM your_table_name LIMIT 10;"

echo "Querying PostgreSQL to verify results in output_seatunnel..."
docker exec -it postgres psql -U postgres -d postgres -c "SELECT * FROM output_seatunnel LIMIT 10;"

echo "Test completed."
