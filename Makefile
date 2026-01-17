.PHONY: help deploy-icinga start-icinga stop-icinga restart-icinga logs-icinga clean-icinga status-icinga check-docker-compose check-icinga-clone

.DEFAULT_GOAL := help

# Detect docker-compose command
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)
ifndef DOCKER_COMPOSE
	DOCKER_COMPOSE := $(shell command -v docker 2> /dev/null)
	ifdef DOCKER_COMPOSE
		DOCKER_COMPOSE := docker compose
	endif
endif

REPO_URL = https://github.com/lippserd/docker-compose-icinga.git

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

check-icinga-clone:
	@if [ ! -d "docker-compose-icinga" ]; then \
		echo "Cloning repository..."; \
		git clone $(REPO_URL); \
	else \
		echo "Repository already exists. Pulling latest changes..."; \
		cd docker-compose-icinga && git pull; \
	fi

help:
	@echo "Icinga2 with IcingaWeb2 Deployment"
	@echo "===================================="
	@echo "Available targets:"
	@echo "  deploy-icinga    - Deploy Icinga2 and IcingaWeb2 stack"
	@echo "  start-icinga     - Start the Icinga stack"
	@echo "  stop-icinga      - Stop the Icinga stack"
	@echo "  restart-icinga   - Restart the Icinga stack"
	@echo "  logs-icinga      - Show logs from all Icinga containers"
	@echo "  status-icinga    - Show status of Icinga containers"
	@echo "  clean-icinga     - Stop and remove all Icinga containers and volumes"
	@echo ""
	@echo "Access:"
	@echo "  IcingaWeb2:      http://localhost:8080"
	@echo "  Icinga2 API:     https://localhost:5665"
	@echo "  Default user:    icingaadmin"
	@echo "  Default pass:    icinga (or set ICINGAWEB_ADMIN_PASSWORD)"

deploy-icinga: check-docker-compose check-icinga-clone
	@echo "Deploying Icinga2 with IcingaWeb2..."
	@echo "Starting Icinga stack..."
	cd docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER up -d
	@echo ""
	@echo "Deployment complete!"
	@echo "===================================="
	@echo "IcingaWeb2 is available at: http://localhost:8080"
	@echo "Username: icingaadmin"
	@echo "Password: icinga"
	@echo "API Username: icingaweb"
	@echo "API Password: icingaweb"
	@echo ""
	@echo "Run 'make logs-icinga' to view logs"

start-icinga: check-docker-compose check-icinga-clone
	@echo "Starting Icinga stack..."
	@cd docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER start
	@echo "Stack started successfully!"

stop-icinga: check-docker-compose check-icinga-clone
	@echo "Stopping Icinga stack..."
	@cd docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER stop
	@echo "Stack stopped successfully!"

restart-icinga: check-docker-compose check-icinga-clone
	@echo "Restarting Icinga stack..."
	@cd docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER restart
	@echo "Stack restarted successfully!"

logs-icinga: check-docker-compose check-icinga-clone
	@cd docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER logs -f

status-icinga: check-docker-compose check-icinga-clone
	@echo "Icinga Container Status:"
	@echo "========================"
	@cd docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER ps

clean-icinga: check-docker-compose check-icinga-clone
	@echo "WARNING: This will remove all containers, volumes, and the cloned repository!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Stopping and removing Icinga stack..."; \
		cd docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER down -v; \
		cd .. && rm -rf docker-compose-icinga; \
		echo "Cleanup complete!"; \
	else \
		echo "Cancelled."; \
	fi
