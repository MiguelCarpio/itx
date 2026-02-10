.DEFAULT_GOAL := help

.PHONY: help deploy-gns3

deploy-gns3:
	@echo "Setting up GNS3 environment..."
	python3 -m venv --system-site-packages ~/GNS3
	@echo "Installing GNS3 packages..."
	bash -c "source ~/GNS3/bin/activate && pip3 install -U gns3-gui gns3-server"
	@echo "Creating GNS3 configuration directories..."
	mkdir -p /ITX_dir/$${USER}/GNS3/.local/share/GNS3/{appliances,configs,images,projects,symbols,docker}
	@echo "Configuring GNS3..."
	@GNS3_VERSION=$$(bash -c "source ~/GNS3/bin/activate && gns3 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1" || echo "3.0"); \
	GNS3_CONFIG_DIR=$$HOME/.config/GNS3/$$GNS3_VERSION; \
	echo "Using config directory: $$GNS3_CONFIG_DIR"; \
	echo "Creating GNS3 server configuration..."; \
	cat > "$$GNS3_CONFIG_DIR/gns3_server.conf" <<'EOF'
[Server]
resources_path = /ITX_dir/$${USER}/GNS3/.local/share/GNS3
images_path = /ITX_dir/$${USER}/GNS3/.local/share/GNS3/images
projects_path = /ITX_dir/$${USER}/GNS3/.local/share/GNS3/projects
appliances_path = /ITX_dir/$${USER}/GNS3/.local/share/GNS3/appliances
symbols_path = /ITX_dir/$${USER}/GNS3/.local/share/GNS3/symbols
configs_path = /ITX_dir/$${USER}/GNS3/.local/share/GNS3/configs

[Docker]
enabled = true
EOF
	echo "Updating GNS3 GUI configuration..."; \
	if [ -f "$$GNS3_CONFIG_DIR/gns3_gui.conf" ]; then \
		sed -i "s|$$HOME/GNS3|/ITX_dir/$$USER/GNS3/.local/share/GNS3|g" "$$GNS3_CONFIG_DIR/gns3_gui.conf"; \
		sed -i 's|"telnet_console_command": "xterm -T \\"{name}\\" -e \\"telnet {host} {port}\\""|"telnet_console_command": "xterm -fa Monospace -fs 12 -geometry 120x40 -sb -T \\"{name}\\" -e \\"telnet {host} {port}\\""|' "$$GNS3_CONFIG_DIR/gns3_gui.conf"; \
		echo "GNS3 GUI configuration updated at $$GNS3_CONFIG_DIR/gns3_gui.conf"; \
	else \
		echo "Warning: gns3_gui.conf not found at $$GNS3_CONFIG_DIR. Start GNS3 once to generate it, then run this target again."; \
	fi
	@echo "GNS3 deployment complete!"
	@echo "Run 'source ~/GNS3/bin/activate && gns3' to start GNS3"

