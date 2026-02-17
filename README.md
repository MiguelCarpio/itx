# itx
Infraestructura i Tecnologia de Xarxes

## Deployment

### 1. Clone the Repository and Switch Branch

```bash
git clone https://github.com/MiguelCarpio/itx.git
cd itx
git switch icinga2
```

### 2. Deploy Icinga Lab Environment

```bash
make deploy-icinga-lab
```

This command will:
- Create the working directory at `/ITX_dir/$USER/icinga-lab`
- Clone the docker-compose-icinga repository from https://github.com/lippserd/docker-compose-icinga.git
- Deploy Icinga2 with IcingaWeb2
- Deploy monitoring target services (Nginx, DNS, SFTP, Redis, MariaDB, MailHog)

### 3. Access Icinga Web Interface

- **IcingaWeb2**: http://localhost:8080
- **Icinga2 API**: https://localhost:5665
- **Username**: `icingaadmin`
- **Password**: `icinga`

### 4. Monitoring Target Services

After deployment, the following services are available for monitoring:

| Service | Internal (container) | External (host) |
|---------|---------------------|-----------------|
| Nginx Web | monitoring-nginx:80 | http://localhost:8081 |
| DNS Server | monitoring-dns:53 | localhost:15353 |
| SFTP Server | monitoring-sftp:22 | localhost:2222 (testuser/testpass) |
| Redis | monitoring-redis:6379 | localhost:6379 |
| MariaDB | monitoring-mariadb:3306 | localhost:3307 (root/mariapass) |
| MailHog SMTP | monitoring-smtp:1025 | localhost:1025 |
| MailHog Web | monitoring-smtp:8025 | http://localhost:8025 |

### 5. Management Commands

```bash
make start-icinga-lab    # Start all services
make stop-icinga-lab     # Stop all services
make restart-icinga-lab  # Restart all services
make status-icinga-lab   # Show container status
make logs-icinga-lab     # Show logs
make clean-icinga-lab    # Remove all containers and volumes
```

## Monitor Hosts and Services

> **NOTE:** After any change in Icinga Director, you must deploy the configuration. Navigate to **Icinga Director** → **Activity log** and click **Deploy # pending changes** to apply your modifications.

### 1. Create a Host Template

Host templates define default monitoring behavior for hosts.

1. Navigate to **Icinga Director** → **Hosts** → **Host Templates**
2. Click **Add** to create a new host template
3. Configure the template:
   - **Template name**: `$USER-servers`
   - **Check command**: `ping4`
   - **Check interval**: `5m`
   - **Retry interval**: `1m`
   - **Max check attempts**: `3`
4. Click **Add** to save

### 2. Create a Hostgroup

Hostgroups organize hosts into logical groups for easier management and filtering.

1. Navigate to **Icinga Director** → **Hosts** → **Host Groups**
2. Click **Add** to create a new hostgroup
3. Configure the hostgroup:
   - **Hostgroup name**: e.g., `web-servers`
   - **Display name**: e.g., `Web Servers`
4. Click **Add** to save

### 3. Create a Host

1. Navigate to **Icinga Director** → **Hosts**
2. Click **Add** to create a new host
3. Configure the host:
   - **Host Template**: Select `$USER-servers`
   - **Display name**: `$USER-nginx`
   - **Host name**: e.g., `$USER-nginx`
   - **Host Address**: `monitoring-nginx` (or IP address)
   - **Groups**: Select the hostgroup (e.g., `web-servers`)
4. Click **Add** to save
5. Navigate to **Icinga Director** → **Activity log** and click **Deploy # pending changes**

### 3. Create a Custom Port Variable in Commands

To monitor services on custom ports (e.g., HTTP on port 80):

1. Navigate to **Icinga Director** → **Commands** → **External Commands**
2. Find and edit the `http` command
3. Add custom fields:
   - Click **Fields** tab
   - Add field: `$http_port$`
     - **Field name**: `$http_port$`
     - **Caption**: `http_port`
4. Click **Add** to save

### 4. Create a Service Template

Service templates define default monitoring behavior for services.

1. Navigate to **Icinga Director** → **Services** → **Service Templates**
2. Click **Add** to create a new service template
3. Configure the template:
   - **Name**: `web-services`
   - **Check interval**: `5m`
   - **Retry interval**: `1m`
   - **Max check attempts**: `3`
4. Click **Add** to save

### 5. Create a Servicegroup

Servicegroups organize services into logical groups for easier management and filtering.

1. Navigate to **Icinga Director** → **Services** → **Service Groups**
2. Click **Add** to create a new servicegroup
3. Configure the servicegroup:
   - **Servicegroup name**: e.g., `web-services`, `database-services`, or `network-services`
   - **Display name**: e.g., `Web Services`
4. Click **Add** to save
5. Click **Store**

### 7. Create a Monitor Service to the Host

1. Navigate to **Icinga Director** → **Services** → **Single Services**
2. Click **Add** to create a new service
3. Configure the service:
   - **Name**: e.g., `Nginx`
   - **Imports**: Select `web-services`
   - **Host**: Select the host created earlier (e.g., `$USER-nginx`)
   - **Check command**: Select `http`
   - **Groups**: Select the servicegroup (e.g., `web-services`)
   - **Check command**: `http`
   - **Custom properties** (if using custom port):
     - `http_port`: `80`
4. Click **Add** to save
5. Navigate to **Icinga Director** → **Activity log** and click **Deploy # pending changes**

### 8. Create a Grid

Grids (Dashboards) provide visual monitoring overview with filtering options using hostgroups and servicegroups.

1. Navigate to **Icinga Director** → **Dashboards** or **IcingaWeb2** → **Dashboards**
2. Click **Add Dashboard** or **Create New**
3. Configure the dashboard:
   - **Dashboard name**: e.g., `Monitoring Overview`
4. Add Dashlets (widgets):
   - Click **Add Dashlet**
   - Choose dashlet type:
     - **Service Grid**: Shows services by host
     - **Host Problems**: Shows problematic hosts
     - **Service Problems**: Shows problematic services
     - **Tactical Overview**: Shows overall system status
5. Configure each dashlet:
   - Set filters using hostgroups/servicegroups:
     - **By Hostgroup**: e.g., `hostgroup=monitoring-targets`
     - **By Servicegroup**: e.g., `servicegroup=web-services`
     - **By Service State**: e.g., `service.state!=0` (show only problems)
     - **By Host State**: e.g., `host.state!=0` (show only down hosts)
   - Set refresh intervals
6. Arrange dashlets by dragging and dropping
7. Click **Save** to save the dashboard

#### Example Grid Configurations

**Service Grid Dashlet (Filtered by Hostgroup)**:
- **Title**: `Monitoring Target Services`
- **Columns**: Host, Service, Status, Last Check, Duration
- **Filter**: `hostgroup=monitoring-targets`
- **Refresh interval**: `30s`

**Service Grid Dashlet (Filtered by Servicegroup)**:
- **Title**: `Web Services`
- **Columns**: Host, Service, Status, Last Check, Duration
- **Filter**: `servicegroup=web-services`
- **Refresh interval**: `30s`

**Host Problems Dashlet (Filtered by Hostgroup)**:
- **Title**: `Monitoring Targets - Problems`
- **Filter**: `hostgroup=monitoring-targets&host.state!=0`
- **Refresh interval**: `30s`

**Service Problems Dashlet (Filtered by Servicegroup)**:
- **Title**: `Web Services - Problems`
- **Filter**: `servicegroup=web-services&service.state!=0`
- **Refresh interval**: `30s`

**Tactical Overview Dashlet**:
- **Title**: `System Overview`
- **Shows**: Total hosts/services, UP/DOWN counts, problem statistics
- **Filter**: None (all) or specific `hostgroup=monitoring-targets`
- **Refresh interval**: `30s`