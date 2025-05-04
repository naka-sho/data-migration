up:
	docker compose up -d

re-up:
	docker compose up -d --build --force-recreate

# Make the test script executable and run it
test-seatunnel:
	chmod +x test-seatunnel.sh
	./test-seatunnel.sh
