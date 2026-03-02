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

## Getting Started with Prometheus

### 1. Access Prometheus UI

Open your browser and navigate to:
```
http://localhost:9090/
```

This is the Prometheus web interface where you can query metrics, view targets, and explore your monitoring data.

### 2. Check Scrape Targets

To verify that Prometheus is successfully scraping metrics from all configured targets:

1. In the Prometheus UI, click on **Status** in the top menu
2. Select **Targets** from the dropdown

You should see all configured targets with their status:
- **prometheus** - Prometheus monitoring itself
- **node_exporter** - System metrics from Node Exporter
- **simple_server** - Metrics from the demo Ping application

All targets should show as **UP** (green) if everything is working correctly.

### 3. Explore Raw Metrics

Each target exposes its metrics at a `/metrics` endpoint. You can view the raw metrics directly:

**Node Exporter Metrics**
```
http://localhost:9100/metrics
```
System-level metrics including CPU, memory, disk, and network statistics.

Example metrics:
- `node_cpu_seconds_total` - CPU time spent in different modes
- `node_memory_MemAvailable_bytes` - Available system memory
- `node_disk_io_time_seconds_total` - Disk I/O statistics

**Prometheus Metrics (self-monitoring)**
```
http://localhost:9090/metrics
```
Prometheus internal metrics about its own performance.

Example metrics:
- `prometheus_http_requests_total` - HTTP requests to Prometheus
- `prometheus_tsdb_head_samples_appended_total` - Samples added to the database
- `go_goroutines` - Number of goroutines in the Prometheus process

**Simple Server Metrics (Ping App)**
```
http://localhost:8090/metrics
```
Custom application metrics from the demo Ping application.

Example metrics:
- `ping_request_count` - Number of times the `/ping` endpoint was called
- `go_gc_duration_seconds` - Garbage collection duration
- `process_cpu_seconds_total` - CPU time used by the process

## Prometheus Metric Types

Prometheus supports four types of metrics:

- **Counter** - A value that only increases or resets to zero
- **Gauge** - A value that can go up or down
- **Histogram** - Samples observations and counts them in configurable buckets
- **Summary** - Similar to histogram, provides quantiles over a sliding time window

### Counter

A **Counter** is a metric value that can only increase or reset (return to zero). The value cannot decrease below the previous value. Counters are ideal for tracking cumulative metrics like:
- Number of requests served
- Number of errors encountered
- Total bytes transferred
- Number of tasks completed

**Key Functions for Counters:**

**`rate()`** - The rate() function in PromQL takes the history of metrics over a time frame and calculates how fast the value is increasing per second. Rate is applicable on counter values only.

**`increase()`** - Calculates the total increase in a counter over a specified time range.

**Example Counter Metric**

First, click on **Graph** tab, type the metric `node_cpu_seconds_total` in the Expression bar and click on Execute.

```
# TYPE node_cpu_seconds_total counter
node_cpu_seconds_total{cpu="0",mode="user"} 3148.2
node_cpu_seconds_total{cpu="0",mode="system"} 2747.7
node_cpu_seconds_total{cpu="0",mode="idle"} 1383852.78
```

**What it tracks:** Total CPU time spent in different modes (user, system, idle, etc.) since boot

**Query Examples**

**Using `rate()` - CPU usage percentage**

Type the below query in the query bar and click on Execute:

```promql
rate(node_cpu_seconds_total{cpu="0",mode="user"}[5m]) * 100
```

**Example return value:** `12.5` *(this value changes over time based on actual CPU usage)*

**Meaning:** CPU core 0 is spending **12.5% of time** running user-space processes (averaged over the last 5 minutes)

**Check the Graph tab:** You'll see a line graph showing how CPU usage changes over time. The line represents the per-second rate at each moment - higher points indicate increased CPU activity.

**Using `increase()` - Total CPU time consumed**

Type the below query in the query bar and click on Execute:

```promql
increase(node_cpu_seconds_total{cpu="0",mode="user"}[1h])
```

**Example return value:** `450` *(this value changes over time based on actual CPU usage)*

**Meaning:** CPU core 0 spent **450 seconds (7.5 minutes)** running user processes in the last hour

**Check the Graph tab:** You'll see a line graph showing the total increase over a sliding 1-hour window. Each point shows how much CPU time was consumed in the hour leading up to that moment.

### Gauge

A **Gauge** is a metric value that can go up and down. Unlike counters that only increase, gauges represent a current state or measurement at a specific point in time. Gauges are ideal for tracking metrics like:
- Current memory usage
- Number of active connections
- Temperature readings
- CPU load average
- Queue size

**Key Characteristics:**

**Current value** - Gauges represent the current state, not cumulative totals. You can query them directly without needing rate() or increase() functions.

**Can decrease** - Unlike counters, gauge values can both increase and decrease naturally.

**Example Gauge Metrics**

**Monitoring current goroutines**

First, click on **Graph** tab, type the metric `go_goroutines` in the Expression bar and click on Execute.

```
# TYPE go_goroutines gauge
go_goroutines 42
```

**What it tracks:** The current number of goroutines (concurrent execution threads) running in the Prometheus process

**Query Example:**

Type the below query in the query bar and click on Execute:

```promql
go_goroutines
```

**Example return value:** `42` *(this value changes based on Prometheus workload)*

**Meaning:** The Prometheus server currently has **42 goroutines** running

**Check the Graph tab:** You'll see a line graph showing how the number of goroutines fluctuates over time - increasing when Prometheus is busier and decreasing when idle.

**Monitoring available memory**

Type the metric `node_memory_MemAvailable_bytes` in the Expression bar and click on Execute.

```
# TYPE node_memory_MemAvailable_bytes gauge
node_memory_MemAvailable_bytes 2147483648
```

**What it tracks:** The amount of memory (in bytes) currently available for use on the system

**Query Example:**

Type the below query in the query bar and click on Execute:

```promql
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024
```

**Example return value:** `2.0` *(this value changes based on system memory usage)*

**Meaning:** The system currently has **2.0 GB** of memory available

**Check the Graph tab:** You'll see a line graph showing how available memory changes over time - decreasing when applications use more memory and increasing when memory is freed.
