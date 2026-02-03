.PHONY: help check-docker-compose check-icinga-clone list-compose stop-all-compose deploy-icinga-lab start-icinga-lab stop-icinga-lab restart-icinga-lab status-icinga-lab logs-icinga-lab clean-icinga-lab

.DEFAULT_GOAL := help

# Working directory
ICINGA_LAB_DIR := /ITX_dir/$(shell echo $$USER)/icinga-lab

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
	@echo "Creating working directory $(ICINGA_LAB_DIR)..."
	@mkdir -p $(ICINGA_LAB_DIR)
	@if [ ! -d "$(ICINGA_LAB_DIR)/docker-compose-icinga" ]; then \
		echo "Cloning repository..."; \
		cd $(ICINGA_LAB_DIR) && git clone $(REPO_URL); \
	else \
		echo "Repository already exists. Pulling latest changes..."; \
		cd $(ICINGA_LAB_DIR)/docker-compose-icinga && git pull; \
	fi
	@echo "Copying monitoring target configuration files..."
	@cp -r nginx-html coredns docker-compose-monitoring-targets.yml icinga2-monitoring-targets.conf $(ICINGA_LAB_DIR)/ 2>/dev/null || true
	@echo "Fixing paths in docker-compose.yml..."
	@cd $(ICINGA_LAB_DIR)/docker-compose-icinga && \
	git checkout docker-compose.yml && \
	sed -i '/^version:/d' docker-compose.yml && \
	sed -i 's|\./icingadb.conf:|'$$(pwd)'/icingadb.conf:|g' docker-compose.yml && \
	sed -i 's|\./icingaweb-api-user.conf:|'$$(pwd)'/icingaweb-api-user.conf:|g' docker-compose.yml && \
	sed -i 's|\./init-icinga2.sh:|'$$(pwd)'/init-icinga2.sh:|g' docker-compose.yml && \
	sed -i 's|\./icinga2.conf.d:|'$$(pwd)'/icinga2.conf.d:|g' docker-compose.yml && \
	sed -i 's|\./env/mysql/:|'$$(pwd)'/env/mysql/:|g' docker-compose.yml

help:
	@echo "Icinga2 with IcingaWeb2 Deployment"
	@echo "===================================="
	@echo "Icinga Lab (Icinga + Monitoring Targets):"
	@echo "  deploy-icinga-lab   - Deploy Icinga2 and all monitoring target services"
	@echo "  start-icinga-lab    - Start Icinga stack and all monitoring targets"
	@echo "  stop-icinga-lab     - Stop Icinga stack and all monitoring targets"
	@echo "  restart-icinga-lab  - Restart Icinga stack and all monitoring targets"
	@echo "  status-icinga-lab   - Show status of all containers"
	@echo "  logs-icinga-lab     - Show logs from all containers"
	@echo "  clean-icinga-lab    - Remove all containers, volumes, and repository"
	@echo ""
	@echo "Docker Compose Management:"
	@echo "  list-compose     - List all Docker Compose projects"
	@echo "  stop-all-compose - Stop all Docker Compose projects (requires jq)"
	@echo ""
	@echo "Access:"
	@echo "  IcingaWeb2:      http://localhost:8080"
	@echo "  Icinga2 API:     https://localhost:5665"
	@echo "  Default user:    icingaadmin"
	@echo "  Default pass:    icinga (or set ICINGAWEB_ADMIN_PASSWORD)"

list-compose: check-docker-compose
	@echo "Docker Compose Projects:"
	@echo "========================"
	@$(DOCKER_COMPOSE) ls -a

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

deploy-icinga-lab: check-docker-compose check-icinga-clone
	@echo "Deploying Icinga2 Lab Environment"
	@echo "===================================="
	@echo ""
	@echo "Step 1: Deploying Icinga2 with IcingaWeb2..."
	@cd $(ICINGA_LAB_DIR)/docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER up -d
	@echo ""
	@echo "Step 2: Deploying monitoring target services..."
	@cd $(ICINGA_LAB_DIR) && $(DOCKER_COMPOSE) -p icinga-$$USER -f docker-compose-monitoring-targets.yml up -d
	@echo ""
	@echo "================================"
	@echo "Icinga Lab Deployment Complete!"
	@echo "================================"
	@echo ""
	@echo "Icinga Services:"
	@echo "  IcingaWeb2:      http://localhost:8080"
	@echo "  Icinga2 API:     https://localhost:5665"
	@echo "  Username:        icingaadmin"
	@echo "  Password:        icinga"
	@echo ""
	@echo "Monitoring Target Services:"
	@echo "  Service         Internal (container)       External (host)"
	@echo "  --------------------------------------------------------------------"
	@echo "  Nginx Web:      monitoring-nginx:80        http://localhost:8081"
	@echo "  DNS Server:     monitoring-dns:53          localhost:15353"
	@echo "  SFTP Server:    monitoring-sftp:22         localhost:2222 (testuser/testpass)"
	@echo "  Redis:          monitoring-redis:6379      localhost:6379"
	@echo "  MariaDB:        monitoring-mariadb:3306    localhost:3307 (root/mariapass)"
	@echo "  MailHog SMTP:   monitoring-smtp:1025       localhost:1025"
	@echo "  MailHog Web:    monitoring-smtp:8025       http://localhost:8025"

start-icinga-lab: check-docker-compose check-icinga-clone
	@echo "Starting Icinga stack..."
	@cd $(ICINGA_LAB_DIR)/docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER start
	@echo "Starting monitoring target services..."
	@cd $(ICINGA_LAB_DIR) && $(DOCKER_COMPOSE) -p icinga-$$USER -f docker-compose-monitoring-targets.yml start
	@echo "All services started successfully!"

stop-icinga-lab: check-docker-compose check-icinga-clone
	@echo "Stopping monitoring target services..."
	@cd $(ICINGA_LAB_DIR) && $(DOCKER_COMPOSE) -p icinga-$$USER -f docker-compose-monitoring-targets.yml stop
	@echo "Stopping Icinga stack..."
	@cd $(ICINGA_LAB_DIR)/docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER stop
	@echo "All services stopped successfully!"

restart-icinga-lab: check-docker-compose check-icinga-clone
	@echo "Restarting Icinga stack..."
	@cd $(ICINGA_LAB_DIR)/docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER restart
	@echo "Restarting monitoring target services..."
	@cd $(ICINGA_LAB_DIR) && $(DOCKER_COMPOSE) -p icinga-$$USER -f docker-compose-monitoring-targets.yml restart
	@echo "All services restarted successfully!"

status-icinga-lab: check-docker-compose check-icinga-clone
	@echo "Icinga Container Status:"
	@echo "========================"
	@cd $(ICINGA_LAB_DIR)/docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER ps
	@echo ""
	@echo "Monitoring Target Status:"
	@echo "========================="
	@cd $(ICINGA_LAB_DIR) && $(DOCKER_COMPOSE) -p icinga-$$USER -f docker-compose-monitoring-targets.yml ps

logs-icinga-lab: check-docker-compose check-icinga-clone
	@echo "Showing logs from all services (Ctrl+C to exit)..."
	@echo "===================================================="
	@cd $(ICINGA_LAB_DIR)/docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER logs --tail=50
	@cd $(ICINGA_LAB_DIR) && $(DOCKER_COMPOSE) -p icinga-$$USER -f docker-compose-monitoring-targets.yml logs -f

clean-icinga-lab: check-docker-compose check-icinga-clone
	@echo "WARNING: This will remove all containers, volumes, and the cloned repository!"
	@bash -c 'read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Stopping and removing monitoring targets..."; \
		cd $(ICINGA_LAB_DIR) && $(DOCKER_COMPOSE) -p icinga-$$USER -f docker-compose-monitoring-targets.yml down -v; \
		echo "Stopping and removing Icinga stack..."; \
		cd $(ICINGA_LAB_DIR)/docker-compose-icinga && $(DOCKER_COMPOSE) -p icinga-$$USER down -v; \
		echo "Removing $(ICINGA_LAB_DIR)..."; \
		rm -rf $(ICINGA_LAB_DIR); \
		echo "Cleanup complete!"; \
	else \
		echo "Cancelled."; \
	fi'
