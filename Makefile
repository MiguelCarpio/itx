.DEFAULT_GOAL := help

.PHONY: help zip-autograder

# Display help information
help:
	@echo "Available targets:"
	@echo "=================="
	@echo ""
	@echo "  make help           - Show this help message"
	@echo "  make zip-autograder - Create autograder.zip for Gradescope upload"
	@echo ""

# Create autograder.zip for Gradescope
zip-autograder:
	@echo "Creating autograder.zip..."
	@echo "=========================="
	@if [ ! -d "autograder" ]; then \
		echo "Error: autograder directory not found"; \
		exit 1; \
	fi
	@cd autograder && zip -r ../autograder.zip setup.sh run_autograder verify_config.py expected_configs.json
	@echo ""
	@echo "✓ autograder.zip created successfully!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Go to Gradescope and create a Programming Assignment"
	@echo "  2. Upload autograder.zip"
	@echo "  3. Students should submit files named: HQ1-config.txt, HQ2-config.txt, HQ3-config.txt"
	@echo ""
