# itx
Infraestructura i Tecnologia de Xarxes

## Makefile Commands

This project includes a Makefile with several useful Docker and Docker Compose management commands.

### Available Commands

- **`make help`** - Display all available Makefile targets with descriptions
- **`make list-compose`** - List all running Docker Compose projects on your system
- **`make stop-all-compose`** - Stop all Docker Compose projects (requires `jq` to be installed)
- **`make install-docker`** - Install Docker and Docker Compose on your system

### Prerequisites

- **For Docker Compose commands**: Docker and Docker Compose must be installed
- **For `stop-all-compose`**: The `jq` command-line JSON processor must be installed

### Usage Examples

```bash
# See all available commands
make help

# List all Docker Compose projects
make list-compose

# Stop all running Docker Compose projects
make stop-all-compose

# Install Docker and Docker Compose (first-time setup)
make install-docker
```

### Notes

- The Makefile automatically detects whether you're using `docker-compose` or `docker compose`
- After running `make install-docker`, you must start a new session or run `su - $USER` to use Docker without sudo
- The `install-docker` command will skip installation if Docker is already present on your system
