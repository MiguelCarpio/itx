# itx
Infraestructura i Tecnologia de Xarxes

## Table of Contents
- [Makefile Commands](#makefile-commands)
- [Gradescope Autograder](#gradescope-autograder)

---

## Makefile Commands

### Available Commands

- **`make help`** - Display all available Makefile targets with descriptions
- **`make zip-autograder`** - Create autograder.zip for Gradescope upload

### Usage Examples

```bash
# See all available commands
make help

# Package autograder for Gradescope
make zip-autograder
```

---

## Gradescope Autograder

Automated grading system for validating RouterOS/MikroTik device configurations with flexible pattern matching.

### Features

✅ **Flexible IP validation** - Accepts any IP addressing scheme (public or private)  
✅ **Subnet mask validation** - Enforces proper subnetting (/30 for point-to-point, /24 for LANs, /28 for DMZ)  
✅ **Interface flexibility** - Accepts any `ether*` interface without requiring specific numbers  
✅ **Loopback requirement** - Checks for at least one /32 address on lo1 interface  
✅ **Minimum address count** - Validates minimum number of addresses on ether interfaces  
✅ **Pattern matching** - Uses regex for commands with variable parameters (any OSPF router-id, any gateway)  
✅ **Concept validation** - Tests networking understanding, not memorization of specific IPs

### Quick Start

1. **Edit requirements** in `autograder/expected_configs.json`
2. **Build autograder**: `make zip-autograder`
3. **Upload** `autograder.zip` to Gradescope Programming Assignment
4. **Test** with sample submissions before releasing to students

### Configuration Types

The `expected_configs.json` file supports three types of requirements:

#### 1. Exact Match (`type: "exact"`)
Checks for exact command strings (ignoring extra whitespace):

```json
{
  "name": "System Identity",
  "type": "exact",
  "command": "system identity set name=HQ1"
}
```

#### 2. Pattern Match (`type: "pattern"`)
Uses regex to match commands with variable parts:

```json
{
  "name": "OSPF Router ID Configured",
  "type": "pattern",
  "pattern": "routing\\s+ospf\\s+instance\\s+set\\s+.*router-id=",
  "description": "OSPF router-id configured"
}
```

#### 3. IP Address Validation (`type: "ip_addresses"`)
Validates IP address configurations with flexible matching:

```json
{
  "name": "IP Address Configuration",
  "type": "ip_addresses",
  "require_lo1_32": true,
  "min_ether_addresses": 3
}
```

**Options:**
- `require_lo1_32: true` - Requires at least one /32 address on lo1 interface (loopback)
- `min_ether_addresses: N` - Requires at least N IP addresses on ether* interfaces  
- `expected_subnet_masks: [30, 28]` - Array of required subnet masks (e.g., 30 for point-to-point, 28 for DMZ)

### How It Works

The autograder extracts IP address assignments using regex:
```
ip address add address=X.X.X.X/YY interface=ZZZZ
```

**Validation:**
1. **Loopback /32**: At least one `/32` address on interface `lo1` (for OSPF router-id)
2. **Minimum addresses**: Required minimum number of addresses on ether interfaces
3. **Subnet masks**: Required subnet masks must appear (/30 for point-to-point links, /24 or /28 for networks)
4. **OSPF configuration**: Router-id, networks, and backbone area configured
5. **Routing**: Default route exists (for HQ1)

### Student Submission Format

Students must submit three text files:
- `HQ1-config.txt` - RouterOS configuration for HQ1 device
- `HQ2-config.txt` - RouterOS configuration for HQ2 device
- `HQ3-config.txt` - RouterOS configuration for HQ3 device

These can be RouterOS export files (`/export file=HQ1-config`) or manually typed configurations.

### Autograder Files

```
autograder/
├── setup.sh                       # Installs Python dependencies
├── run_autograder                 # Entry point script
├── verify_config.py               # Main grading logic
├── expected_configs.json          # Your requirements (git-ignored, secret)
└── expected_configs.json.example  # Template/reference (tracked in git)
```

### Testing Locally

Use the included test script to validate before uploading to Gradescope:

```bash
# Run the test with sample submissions
python3 test_autograder.py
```

The test simulates the Gradescope environment and shows you exactly what students will see.

**See [TESTING.md](TESTING.md) for detailed testing guide including:**
- How to test different scenarios
- How to create custom test cases
- Understanding test output
- Troubleshooting common issues

### Updating Requirements

1. Edit `autograder/expected_configs.json`
2. Use appropriate requirement types (`exact`, `pattern`, or `ip_addresses`)
3. Rebuild: `make zip-autograder`
4. Re-upload to Gradescope
5. Test with sample submissions

### Network Topology Context

**HQ-1** (back-end firewall):
- DMZ interface: /28 subnet (e.g., 100.10.0.0/28 for servers)
- Point-to-point to HQ-2 and HQ-3: /30 subnets
- Requires default route and OSPF distribute-default
- Required subnets: **/30 and /28**

**HQ-2** (LAN gateway):
- LAN interface: 192.168.100.1/24
- Point-to-point to HQ-1 and HQ-3: /30 subnets
- Required subnets: **/30 and /24**

**HQ-3** (wireless router):
- WLAN: 192.168.200.0/24
- Point-to-point to HQ-1 and HQ-2: /30 subnets
- Required subnets: **/30 only**

All devices form a full mesh using OSPF in the backbone area. The autograder validates proper use of /30 for point-to-point links.
