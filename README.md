# itx
Infraestructura i Tecnologia de Xarxes

## Deployment

### 1. Clone the Repository and Switch Branch

```bash
git clone https://github.com/MiguelCarpio/itx.git
cd itx
git switch grafana
```

### 2. Deploy Prometheus-Grafana-Alertmanager Stack

> [!IMPORTANT]
> Before deploying or starting the prometheus-grafana stack, stop any other running Docker Compose projects with `make stop-all-compose`

```bash
make deploy-prometheus-grafana
```

This command will:
- Create the working directory at `/ITX_dir/$USER/prometheus-grafana-lab`
- Clone the prometheus-alertmanager-tutorial repository from https://github.com/grafana/prometheus-alertmanager-tutorial.git
- Deploy Prometheus, Grafana, and Alertmanager stack
- Start all services

> [!TIP]
> If you are deploying the prometheus-grafana stack on your personal machine, you may need to set a custom directory path. Use the `PROMETHEUS_GRAFANA_LAB_DIR` variable:
> ```bash
> PROMETHEUS_GRAFANA_LAB_DIR=~/prometheus-grafana-lab make deploy-prometheus-grafana
> ```

### 3. Access the Services

After successful deployment, the following services will be available:

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
- **Ping App**: http://localhost:8090/ping

### 4. Additional Commands

See all available commands:
```bash
make help
```

Common operations:
```bash
make start-prometheus-grafana     # Start existing containers
make stop-prometheus-grafana      # Stop running containers
make restart-prometheus-grafana   # Restart all containers
make logs-prometheus-grafana      # Show and follow container logs
make status-prometheus-grafana    # Show container status
make clean-prometheus-grafana     # Stop and remove containers and volumes
```
