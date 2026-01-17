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

# Display help information
help:
	@echo "Available targets:"
	@echo "=================="
	@echo ""
	@echo "  make help              - Show this help message"
	@echo "  make list-compose      - List all Docker Compose projects"
	@echo "  make stop-all-compose  - Stop all Docker Compose projects"
	@echo "  make install-docker    - Install Docker and Docker Compose"
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
