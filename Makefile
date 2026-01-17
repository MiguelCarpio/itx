.PHONY: help deploy-prometheus-grafana start-prometheus-grafana stop-prometheus-grafana restart-prometheus-grafana logs-prometheus-grafana status-prometheus-grafana clean-prometheus-grafana check-docker-compose check-prometheus-grafana-clone

.DEFAULT_GOAL := help

# Detect docker-compose command
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)
ifndef DOCKER_COMPOSE
	DOCKER_COMPOSE := $(shell command -v docker 2> /dev/null)
	ifdef DOCKER_COMPOSE
		DOCKER_COMPOSE := docker compose
	endif
endif

REPO_URL = https://github.com/grafana/prometheus-alertmanager-tutorial.git

help:
	@echo "Available targets:"
	@echo "  deploy-prometheus-grafana   - Deploy Prometheus, Grafana and Alertmanager stack"
	@echo "  start-prometheus-grafana    - Start the Prometheus-Grafana stack"
	@echo "  stop-prometheus-grafana     - Stop the Prometheus-Grafana stack"
	@echo "  restart-prometheus-grafana  - Restart the Prometheus-Grafana stack"
	@echo "  logs-prometheus-grafana     - Show logs from all Prometheus-Grafana containers"
	@echo "  status-prometheus-grafana   - Show status of Prometheus-Grafana containers"
	@echo "  clean-prometheus-grafana    - Stop and remove all Prometheus-Grafana containers and volumes"

check-docker-compose:
	@if [ -z "$(DOCKER_COMPOSE)" ]; then \
		echo "Error: Docker Compose is not installed on this system."; \
		echo ""; \
		echo "To install Docker and Docker Compose, please:"; \
		echo "  1. Switch to the main branch"; \
		echo "  2. Run: make install-docker"; \
		echo ""; \
		exit 1; \
	fi

check-prometheus-grafana-clone:
	@if [ ! -d "prometheus-alertmanager-tutorial" ]; then \
		echo "Cloning repository..."; \
		git clone $(REPO_URL); \
	else \
		echo "Repository already exists. Pulling latest changes..."; \
		cd prometheus-alertmanager-tutorial && git pull; \
	fi

deploy-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Deploying Prometheus-Grafana-Alertmanager stack..."
	@echo "Starting the stack..."
	@cd prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER up -d
	@echo ""
	@echo "Prometheus-Grafana-Alertmanager stack deployed successfully!"
	@echo ""
	@echo "Access the services at:"
	@echo "  - Prometheus:    http://localhost:9090"
	@echo "  - Grafana:       http://localhost:3000"
	@echo "  - Alertmanager:  http://localhost:9093"
	@echo "  - Demo App:      http://localhost:8090"

start-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Starting Prometheus-Grafana stack..."
	@cd prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER start
	@echo "Stack started successfully!"

stop-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Stopping Prometheus-Grafana stack..."
	@cd prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER stop
	@echo "Stack stopped successfully!"

restart-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Restarting Prometheus-Grafana stack..."
	@cd prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER restart
	@echo "Stack restarted successfully!"

logs-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Showing logs from Prometheus-Grafana containers..."
	@cd prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER logs -f

status-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Status of Prometheus-Grafana containers:"
	@cd prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER ps

clean-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Stopping and removing Prometheus-Grafana containers and volumes..."
	@cd prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER down -v
	@echo "Stack cleaned successfully!"
	@echo "To remove the project directory, run: rm -rf prometheus-alertmanager-tutorial"
