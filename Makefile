.DEFAULT_GOAL := help

GNS3_DATA_DIR ?= /ITX_dir/$(shell echo $$USER)/GNS3/.local/share/GNS3

.PHONY: help deploy-gns3 run-gns3 gns3 clean-gns3

help:
	@echo "Available targets:"
	@echo "  deploy-gns3  - Install and configure GNS3"
	@echo "  run-gns3     - Run GNS3 (alias: gns3)"
	@echo "  gns3         - Alias for run-gns3"
	@echo "  clean-gns3   - Remove GNS3 installation and configuration"

deploy-gns3:
	@echo "Setting up GNS3 environment..."
	@python3 -m venv --system-site-packages ~/GNS3
	@echo "Installing GNS3 packages..."
	@bash -c "source ~/GNS3/bin/activate && pip3 install -U gns3-gui gns3-server"
	@echo "Creating GNS3 configuration directories..."
	@mkdir -p $(GNS3_DATA_DIR)/{appliances,configs,images,projects,symbols,docker}
	@echo "Configuring GNS3..."
	@bash -c 'set -e; \
		GNS3_DATA_DIR="$(GNS3_DATA_DIR)"; \
		GNS3_VERSION=$$(source ~/GNS3/bin/activate && gns3 --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+" | head -1 || echo "3.0"); \
		GNS3_CONFIG_DIR=$$HOME/.config/GNS3/$$GNS3_VERSION; \
		echo "Using config directory: $$GNS3_CONFIG_DIR"; \
		echo "Creating GNS3 server configuration..."; \
		mkdir -p "$$GNS3_CONFIG_DIR"; \
		printf "[Server]\nresources_path = $$GNS3_DATA_DIR\nimages_path = $$GNS3_DATA_DIR/images\nprojects_path = $$GNS3_DATA_DIR/projects\nappliances_path = $$GNS3_DATA_DIR/appliances\nsymbols_path = $$GNS3_DATA_DIR/symbols\nconfigs_path = $$GNS3_DATA_DIR/configs\n\n[Docker]\nenabled = true\n" > "$$GNS3_CONFIG_DIR/gns3_server.conf"; \
		if [ ! -f "$$GNS3_CONFIG_DIR/gns3_gui.conf" ]; then \
			echo "Generating GNS3 GUI configuration..."; \
			echo "Starting GNS3 briefly to create config file..."; \
			source ~/GNS3/bin/activate && timeout 10 gns3 >/dev/null 2>&1 || true; \
			sleep 2; \
			if [ ! -f "$$GNS3_CONFIG_DIR/gns3_gui.conf" ]; then \
				echo "Warning: Failed to generate gns3_gui.conf automatically."; \
				echo "Please start GNS3 manually once, then run make deploy-gns3 again."; \
				exit 0; \
			fi; \
		fi; \
		echo "Updating GNS3 GUI configuration..."; \
		sed -i "s|$$HOME/GNS3|$$GNS3_DATA_DIR|g" "$$GNS3_CONFIG_DIR/gns3_gui.conf"; \
		sed -i "s|\"telnet_console_command\": \"xterm -T \\\\\"{name}\\\\\" -e \\\\\"telnet {host} {port}\\\\\"\",|\"telnet_console_command\": \"xterm -fa Monospace -fs 12 -geometry 120x40 -sb -T \\\\\"{name}\\\\\" -e \\\\\"telnet {host} {port}\\\\\"\",|" "$$GNS3_CONFIG_DIR/gns3_gui.conf"; \
			echo "GNS3 GUI configuration updated successfully!"'
	@echo "GNS3 deployment complete!"
	@echo "Run 'make gns3' to start GNS3"

run-gns3:
	@bash -c "source ~/GNS3/bin/activate && gns3"

gns3: run-gns3

clean-gns3:
	@echo "Cleaning GNS3 installation..."
	@echo ""
	@echo "WARNING: This will permanently delete the following:"
	@echo "  - Virtual environment: ~/GNS3"
	@echo "  - Configuration files: ~/.config/GNS3"
	@echo "  - Data directory: $(GNS3_DATA_DIR)"
	@echo ""
	@read -p "Are you sure you want to proceed? (yes/no): " confirm && \
	if [ "$$confirm" != "yes" ]; then \
		echo "Cleanup cancelled."; \
		exit 1; \
	fi
	@echo "Removing virtual environment..."
	@rm -rf ~/GNS3
	@echo "Removing configuration files..."
	@rm -rf ~/.config/GNS3
	@echo "Removing data directories..."
	@rm -rf $(GNS3_DATA_DIR)
	@echo "GNS3 cleanup complete!"

