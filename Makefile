.DEFAULT_GOAL := help

.PHONY: help deploy-gns3 run-gns3 gns3

help:
	@echo "Available targets:"
	@echo "  deploy-gns3  - Install and configure GNS3"
	@echo "  run-gns3     - Run GNS3 (alias: gns3)"
	@echo "  gns3         - Alias for run-gns3"

deploy-gns3:
	@echo "Setting up GNS3 environment..."
	@python3 -m venv --system-site-packages ~/GNS3
	@echo "Installing GNS3 packages..."
	@bash -c "source ~/GNS3/bin/activate && pip3 install -U gns3-gui gns3-server"
	@echo "Creating GNS3 configuration directories..."
	@mkdir -p /ITX_dir/$${USER}/GNS3/.local/share/GNS3/{appliances,configs,images,projects,symbols,docker}
	@echo "Configuring GNS3..."
	@bash -c 'set -e; \
		GNS3_VERSION=$$(source ~/GNS3/bin/activate && gns3 --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+" | head -1 || echo "3.0"); \
		GNS3_CONFIG_DIR=$$HOME/.config/GNS3/$$GNS3_VERSION; \
		echo "Using config directory: $$GNS3_CONFIG_DIR"; \
		echo "Creating GNS3 server configuration..."; \
		mkdir -p "$$GNS3_CONFIG_DIR"; \
		printf "[Server]\nresources_path = /ITX_dir/$$USER/GNS3/.local/share/GNS3\nimages_path = /ITX_dir/$$USER/GNS3/.local/share/GNS3/images\nprojects_path = /ITX_dir/$$USER/GNS3/.local/share/GNS3/projects\nappliances_path = /ITX_dir/$$USER/GNS3/.local/share/GNS3/appliances\nsymbols_path = /ITX_dir/$$USER/GNS3/.local/share/GNS3/symbols\nconfigs_path = /ITX_dir/$$USER/GNS3/.local/share/GNS3/configs\n\n[Docker]\nenabled = true\n" > "$$GNS3_CONFIG_DIR/gns3_server.conf"; \
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
		sed -i "s|$$HOME/GNS3|/ITX_dir/$$USER/GNS3/.local/share/GNS3|g" "$$GNS3_CONFIG_DIR/gns3_gui.conf"; \
		sed -i "s|\"telnet_console_command\": \"xterm -T \\\"{name}\\\" -e \\\"telnet {host} {port}\\\"\"|\"telnet_console_command\": \"xterm -fa Monospace -fs 12 -geometry 120x40 -sb -T \\\"{name}\\\" -e \\\"telnet {host} {port}\\\"\"|" "$$GNS3_CONFIG_DIR/gns3_gui.conf"; \
		echo "GNS3 GUI configuration updated successfully!"'
	@echo "GNS3 deployment complete!"
	@echo "Run 'make gns3' to start GNS3"

run-gns3:
	@bash -c "source ~/GNS3/bin/activate && gns3"

gns3: run-gns3

