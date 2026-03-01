.PHONY: help deploy-prometheus-grafana start-prometheus-grafana stop-prometheus-grafana restart-prometheus-grafana logs-prometheus-grafana status-prometheus-grafana clean-prometheus-grafana check-docker-compose check-prometheus-grafana-clone

.DEFAULT_GOAL := help

# Working directories
PROMETHEUS_GRAFANA_LAB_DIR ?= /ITX_dir/$(shell echo $$USER)/prometheus-grafana-lab
.DEFAULT_GOAL := help

.PHONY: help check-docker-compose list-compose stop-all-compose install-docker

# Detect docker-compose command
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)
ifndef DOCKER_COMPOSE
	DOCKER_COMPOSE := $(shell command -v docker 2> /dev/null)
	ifdef DOCKER_COMPOSE
		DOCKER_COMPOSE := docker compose
	endif
endif

REPO_URL = https://github.com/grafana/prometheus-alertmanager-tutorial.git

# Display help information
help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Prometheus/Grafana/Alertmanager Stack Management"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  make deploy-prometheus-grafana   Deploy and start the complete stack"
	@echo "                                   Services available at:"
	@echo "                                     • Prometheus:   http://localhost:9090"
	@echo "                                     • Grafana:      http://localhost:3000"
	@echo "                                     • Ping App:     http://localhost:8090/ping"
	@echo ""
	@echo "  make start-prometheus-grafana    Start existing containers"
	@echo "  make stop-prometheus-grafana     Stop running containers"
	@echo "  make restart-prometheus-grafana  Restart all containers"
	@echo "  make logs-prometheus-grafana     Show and follow container logs"
	@echo "  make status-prometheus-grafana   Show container status"
	@echo "  make clean-prometheus-grafana    Stop and remove containers and volumes"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Docker Compose Utilities"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  make list-compose                List all Docker Compose projects"
	@echo "  make stop-all-compose            Stop all Docker Compose projects"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Setup & Installation"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  make install-docker              Install Docker and Docker Compose"
	@echo "  make help                        Show this help message"
	@echo ""

# Check if docker compose is available
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
	@echo "Creating working directory $(PROMETHEUS_GRAFANA_LAB_DIR)..."
	@mkdir -p $(PROMETHEUS_GRAFANA_LAB_DIR)
	@if [ ! -d "$(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial" ]; then \
		echo "Cloning repository..."; \
		cd $(PROMETHEUS_GRAFANA_LAB_DIR) && git clone $(REPO_URL); \
	else \
		echo "Repository already exists. Pulling latest changes..."; \
		cd $(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial && git pull; \
	fi

deploy-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Deploying Prometheus-Grafana-Alertmanager stack..."
	@echo "Starting the stack..."
	@cd $(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER up -d
	@echo ""
	@echo "Prometheus-Grafana-Alertmanager stack deployed successfully!"
	@echo ""
	@echo "Access the services at:"
	@echo "  - Prometheus:    http://localhost:9090"
	@echo "  - Grafana:       http://localhost:3000"
	@echo "  - Ping App:      http://localhost:8090/ping"

start-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Starting Prometheus-Grafana stack..."
	@cd $(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER start
	@echo "Stack started successfully!"

stop-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Stopping Prometheus-Grafana stack..."
	@cd $(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER stop
	@echo "Stack stopped successfully!"

restart-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Restarting Prometheus-Grafana stack..."
	@cd $(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER restart
	@echo "Stack restarted successfully!"

logs-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Showing logs from Prometheus-Grafana containers..."
	@cd $(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER logs -f

status-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Status of Prometheus-Grafana containers:"
	@cd $(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER ps

clean-prometheus-grafana: check-docker-compose check-prometheus-grafana-clone
	@echo "Stopping and removing Prometheus-Grafana containers and volumes..."
	@cd $(PROMETHEUS_GRAFANA_LAB_DIR)/prometheus-alertmanager-tutorial && $(DOCKER_COMPOSE) -p prometheus-grafana-$$USER down -v
	@echo "Stack cleaned successfully!"
	@echo "To remove the project directory, run: rm -rf $(PROMETHEUS_GRAFANA_LAB_DIR)"
# List all Docker Compose projects
list-compose: check-docker-compose
	@echo "Docker Compose Projects:"
	@echo "========================"
	@$(DOCKER_COMPOSE) ls

# Stop all Docker Compose projects
stop-all-compose: check-docker-compose
	@echo "Stopping all Docker Compose projects..."
	@echo "========================================"
	@if ! command -v jq >/dev/null 2>&1; then \
		echo "Error: jq is not installed."; \
		echo "Please install jq: sudo dnf install jq"; \
		exit 1; \
	fi
	@$(DOCKER_COMPOSE) ls --format json | jq -r '.[].Name' | while read project; do \
		echo "Stopping project: $$project"; \
		$(DOCKER_COMPOSE) -p $$project stop; \
	done
	@echo ""
	@echo "All Docker Compose projects stopped!"

# Install Docker
install-docker:
	@echo "Installing Docker..."
	@echo "==================="
	@if command -v docker >/dev/null 2>&1; then \
		echo "Docker is already installed:"; \
		docker --version; \
		echo "Skipping installation."; \
	else \
		echo "Cloning docker-install repository..."; \
		sudo git clone https://github.com/docker/docker-install.git /tmp/docker-install; \
		echo "Running Docker installation script (ignoring warnings)..."; \
		cd /tmp/docker-install && sudo ./install.sh || true; \
		echo "Adding user $$USER to docker group..."; \
		sudo usermod -aG docker $$USER; \
		echo "Enabling and starting Docker service..."; \
		sudo systemctl enable docker; \
		sudo systemctl start docker; \
		echo "Cleaning up..."; \
		sudo rm -rf /tmp/docker-install; \
		echo ""; \
		echo "Docker installation complete!"; \
		echo "=============================="; \
		echo "IMPORTANT: You must start a new session to use Docker without sudo."; \
		echo "Please run: su - $$USER"; \
		echo "Or log out and log back in."; \
	fi
