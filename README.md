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
- Deploy monitoring target services (Nginx, DNS, FTP, MariaDB)

---

## Deployed Services

After successful deployment, the following services and tools are available:

### Icinga Web Interface

- **IcingaWeb2**: http://localhost:8080
- **Icinga2 API**: https://localhost:5665
- **Username**: `icingaadmin`
- **Password**: `icinga`

### Monitoring Target Services

The following services are deployed and available for monitoring (internal network access only):

| Service | Container:Port | Credentials |
|---------|----------------|-------------|
| Web | nginx-container:80 | - |
| DNS | dns-container:53 | - |
| FTP | ftp-container:21 | testuser/testpass |
| MariaDB | mariadb-container:3306 | root/mariapass |

### Management Commands

Use these commands to manage your Icinga lab environment:

```bash
make start-icinga-lab    # Start all services
make stop-icinga-lab     # Stop all services
make restart-icinga-lab  # Restart all services
make status-icinga-lab   # Show container status
make logs-icinga-lab     # Show logs
make clean-icinga-lab    # Remove all containers and volumes
```

---

## Monitor Hosts and Services

> **NOTE:** After any change in Icinga Director, you must deploy the configuration. Navigate to **Icinga Director** → **Activity log** and click **Deploy # pending changes** to apply your modifications.

### Monitoring Targets Overview

| Display Name | Host Address | Hostgroup | Services | Servicegroup | Check Command | Custom Fields |
|--------------|--------------|-----------|----------|--------------|---------------|---------------|
| $USER-nginx | nginx-container | web-servers | http | web-checks | http | - |
| $USER-dns | dns-container | network-servers | dns | dns-checks | dns | - |
| $USER-ftp | ftp-container | network-servers | ftp | ftp-checks | ftp | - |
| $USER-mariadb | mariadb-container | database-servers | mysql | database-checks | mysql | mysql_username, mysql_password |
| $USER-mariadb | mariadb-container | database-servers | mysql_query | database-checks | mysql_query | mysql_query_username, mysql_query_password, mysql_query_execute |

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

### 2. Create Hostgroups

Hostgroups organize hosts into logical groups for easier management and filtering.

1. Navigate to **Icinga Director** → **Hosts** → **Host Groups**
2. Click **Add** to create a new hostgroup
3. Configure the hostgroup:
   - **Hostgroup name**: e.g., `web-servers`
   - **Display name**: e.g., `Web Servers`
4. Click **Add** to save
5. Repeat the same process to create `database-servers` and `network-servers` hostgroups

### 3. Create Hosts

1. Navigate to **Icinga Director** → **Hosts** → **Hosts**
2. Click **Add** to create a new host
3. Configure the host:
   - **Host Template**: Select `$USER-servers`
   - **Host name**: `$SERVICE-container` (e.g., `nginx-container`)
   - **Display name**: `$USER-$SERVICE` (e.g., `$USER-nginx`)
   - **Host Address**: `$SERVICE-container` (e.g., `nginx-container`)
   - **Groups**: Select the hostgroup (e.g., `web-servers`)
4. Click **Add** to save
5. Repeat the same process for `dns-container`, `ftp-container`, and `mariadb-container`
6. Navigate to **Icinga Director** → **Activity log** and click **Deploy # pending changes**

### 4. Add Custom Fields to Commands

Commands may require custom fields for credentials, ports, or other parameters.

1. Navigate to **Icinga Director** → **Commands** → **External Commands**
2. Find and edit the `mysql` command
3. Click **Fields** tab
4. Add the following custom fields:
   - Field name: `mysql_username`
   - Field name: `mysql_password`
5. Click **Add**
6. Do the same for `mysql_query` command, adding:
   - Field name: `mysql_query_username`
   - Field name: `mysql_query_password`
   - Field name: `mysql_query_execute`

### 5. Create a Service Template

Service templates define default monitoring behavior for services.

1. Navigate to **Icinga Director** → **Services** → **Service Templates**
2. Click **Add** to create a new service template
3. Configure the template:
   - **Name**: `$USER-services`
   - **Check interval**: `5m`
   - **Retry interval**: `1m`
   - **Max check attempts**: `3`
4. Click **Add** to save

### 6. Create Servicegroups

Servicegroups organize services into logical groups for easier management and filtering.

1. Navigate to **Icinga Director** → **Services** → **Service Groups**
2. Click **Add** to create a new servicegroup
3. Configure the servicegroup:
   - **Servicegroup name**: e.g., `dns-checks`
   - **Display name**: e.g., `DNS Checks`
4. Click **Add** to save
5. Assign services automatically: `service.check_command = dns`
6. Click **Store**
7. Repeat the same process to create `web-checks`, `ftp-checks` and `database-checks` servicegroups with their respective check command assignments

### 7. Create Monitor Services

1. Navigate to **Icinga Director** → **Services** → **Single Services**
2. Click **Add** to create a new service
3. Configure the service:
   - **Name**: e.g., `http`
   - **Imports**: Select `$USER-services`
   - **Host**: Select the host created earlier (e.g., `nginx-container`)
   - **Check command**: Select `http`
4. Click **Add** to save
5. Repeat for all other services (DNS, FTP, MariaDB) with their respective hosts, commands and custom properties
6. Navigate to **Icinga Director** → **Activity log** and click **Deploy # pending changes**

---

## Manage Dashboards

### Create a Dashboard

#### Create Critical Servers Dashlet

1. Navigate to **IcingaWeb2** → **Problems** → **Service Grid**
2. Uncheck **Problems Only**
3. In **Type to search** field, write: `hostgroup.name=web-servers|hostgroup.name=database-servers`
4. Click **Dropdown menu** → **Add to Dashboard**
5. Set **Dashlet Title**: `Critical Servers`
6. Click **New dashboard**
7. Set **New Dashboard Title**: `Monitoring ITX`
8. Click **Add to Dashboard**

#### Create Supporting Servers Dashlet

1. Navigate to **IcingaWeb2** → **Problems** → **Service Grid**
2. Uncheck **Problems Only**
3. In **Type to search** field, write: `hostgroup.name=network-servers`
4. Click **Dropdown menu** → **Add to Dashboard**
5. Set **Dashlet Title**: `Supporting Servers`
6. Select the **Monitoring ITX** dashboard (don't create a new one)
7. Click **Add to Dashboard**