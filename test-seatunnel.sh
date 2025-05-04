#!/bin/bash
# Make the script executable with: chmod +x test-seatunnel.sh

# Exit on error
set -e

echo "Starting containers..."
make up

echo "Waiting for containers to start..."
sleep 10

echo "Creating PostgreSQL tables..."
docker exec -it postgres psql -U postgres -d postgres -c "DROP TABLE IF EXISTS your_table_name, output_seatunnel;"
docker exec -it postgres psql -U postgres -d postgres -f /work/create.sql

echo "Checking sample data file..."
docker exec -it embulk bash -c "zcat /work/try1/csv/sample_01.csv.gz | head -n 10"

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

echo "Checking if there are messages in the Kafka topic..."
docker exec -it kafka kafka-console-consumer --bootstrap-server kafka:29092 --topic quickstart-events --from-beginning --max-messages 5

echo "Running SeaTunnel to process Kafka messages and insert into PostgreSQL..."
docker exec -it seatunnel bash -c "seatunnel --config /work/seatunnel-config.conf --master local"

echo "Checking if data was inserted into output_seatunnel..."
docker exec -it postgres psql -U postgres -d postgres -c "SELECT COUNT(*) FROM output_seatunnel;"

echo "Querying PostgreSQL to verify results in your_table_name..."
docker exec -it postgres psql -U postgres -d postgres -c "SELECT * FROM your_table_name LIMIT 10;"

echo "Querying PostgreSQL to verify results in output_seatunnel..."
docker exec -it postgres psql -U postgres -d postgres -c "SELECT * FROM output_seatunnel LIMIT 10;"

echo "Test completed."
