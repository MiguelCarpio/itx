# itx
Infraestructura i Tecnologia de Xarxes

## GNS3 Setup

This project provides automated deployment and management of GNS3 using a Makefile.

### Prerequisites

- Python 3 with venv support
- Docker support

> [!TIP]
> If you are deploying GNS3 on your personal machine, you may need to set a custom directory path. Use the `GNS3_DATA_DIR` variable:
> ```bash
> GNS3_DATA_DIR=~/gns3-data make deploy-gns3
> ```

### Available Commands

Run `make` or `make help` to see all available targets:

#### Deploy GNS3

1. Clone the Repository and Switch Branch

```bash
git clone https://github.com/MiguelCarpio/itx.git
cd itx
git switch gns3
```

2. Run the deployment

```bash
make deploy-gns3
```

This installs and configures GNS3 by:
- Creating a Python virtual environment at `~/GNS3`
- Installing `gns3-gui` and `gns3-server` packages
- Creating data directories in `/ITX_dir/$USER/GNS3/.local/share/GNS3/` (default, configurable via `GNS3_DATA_DIR`)
- Configuring GNS3 server and GUI with custom paths
- Setting up xterm console with improved terminal settings (120x40 geometry, monospace font)

#### Run GNS3
```bash
make run-gns3
# or
make gns3
```
Starts GNS3 GUI using the configured virtual environment.

#### Clean GNS3
```bash
make clean-gns3
```
Completely removes GNS3 installation by:
- Deleting the virtual environment (`~/GNS3`)
- Removing configuration files (`~/.config/GNS3`)
- Removing data directories (`/ITX_dir/$USER/GNS3/.local/share/GNS3`) (default, configurable via `GNS3_DATA_DIR`)

### Directory Structure

After deployment, GNS3 uses the following directories:
- **Virtual environment**: `~/GNS3/`
- **Configuration**: `~/.config/GNS3/`
- **Data storage**: `/ITX_dir/$USER/GNS3/.local/share/GNS3/` (default, configurable via `GNS3_DATA_DIR`)
  - `appliances/` - Network appliance definitions
  - `configs/` - Device configurations
  - `images/` - Virtual machine and router images
  - `projects/` - GNS3 project files
  - `symbols/` - Custom device icons
  - `docker/` - Docker container data