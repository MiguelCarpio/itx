#!/usr/bin/env python3
import json
import os
import re

def load_expected_configs():
    """Load expected configurations from JSON file"""
    config_file = os.path.join(os.path.dirname(__file__), 'expected_configs.json')

    if not os.path.exists(config_file):
        raise FileNotFoundError(f"Expected configuration file not found: {config_file}")

    with open(config_file, 'r') as f:
        return json.load(f)

def normalize_command(cmd):
    """Normalize commands by removing extra spaces and standardizing format"""
    return ' '.join(cmd.split()).strip()

def is_private_ip(ip_str):
    """Check if an IP address is in a private range"""
    # Parse IP address (without subnet)
    parts = ip_str.split('.')
    if len(parts) != 4:
        return False

    try:
        octets = [int(p) for p in parts]
    except ValueError:
        return False

    # Check private ranges:
    # 10.0.0.0/8
    if octets[0] == 10:
        return True
    # 172.16.0.0/12
    if octets[0] == 172 and 16 <= octets[1] <= 31:
        return True
    # 192.168.0.0/16
    if octets[0] == 192 and octets[1] == 168:
        return True

    return False

def extract_ip_addresses(config_text):
    """Extract IP address assignments from configuration"""
    # Pattern: ip address add address=X.X.X.X/YY interface=ZZZZ
    pattern = r'ip\s+address\s+add\s+address=(\d+\.\d+\.\d+\.\d+)/(\d+)\s+interface=(\S+)'
    matches = re.findall(pattern, config_text, re.IGNORECASE)
    # Return list of tuples: (ip, subnet_mask, interface)
    return [(ip, subnet, iface) for ip, subnet, iface in matches]

def check_pattern_requirement(config_text, requirement):
    """Check requirements that use pattern matching (regex)"""
    req_type = requirement.get('type', 'exact')

    if req_type == 'ip_addresses':
        # Extract all IP addresses from config
        ip_assignments = extract_ip_addresses(config_text)

        results = []
        errors = []

        # Check for required /32 on lo1 (loopback)
        if 'require_lo1_32' in requirement and requirement['require_lo1_32']:
            lo1_32_addresses = [(ip, subnet, iface) for ip, subnet, iface in ip_assignments
                               if iface == 'lo1' and subnet == '32']

            if len(lo1_32_addresses) >= 1:
                results.append({
                    'passed': True,
                    'message': f"Found {len(lo1_32_addresses)} /32 address(es) on lo1"
                })
            else:
                errors.append("Missing at least one /32 address on interface lo1 (loopback)")

        # Check for private IP addresses on ether interfaces
        if 'require_private_ips_on_ether' in requirement and requirement['require_private_ips_on_ether']:
            ether_addresses = [(ip, subnet, iface) for ip, subnet, iface in ip_assignments
                              if iface.startswith('ether')]

            if not ether_addresses:
                errors.append("No IP addresses configured on ether interfaces")
            else:
                non_private = [ip for ip, subnet, iface in ether_addresses if not is_private_ip(ip)]
                if non_private:
                    errors.append(f"Found public/invalid IP addresses on ether interfaces: {', '.join(non_private)}")
                else:
                    results.append({
                        'passed': True,
                        'message': f"All {len(ether_addresses)} ether interface(s) use private IP addresses"
                    })

        # Check minimum number of addresses on ether interfaces
        if 'min_ether_addresses' in requirement:
            min_count = requirement['min_ether_addresses']
            ether_addresses = [(ip, subnet, iface) for ip, subnet, iface in ip_assignments
                              if iface.startswith('ether')]

            if len(ether_addresses) >= min_count:
                results.append({
                    'passed': True,
                    'message': f"Found {len(ether_addresses)} IP address(es) on ether interfaces (minimum: {min_count})"
                })
            else:
                errors.append(f"Expected at least {min_count} IP addresses on ether interfaces, found {len(ether_addresses)}")

        # Check for specific subnet masks (optional)
        if 'expected_subnet_masks' in requirement:
            expected_masks = requirement['expected_subnet_masks']
            found_masks = set(subnet for ip, subnet, iface in ip_assignments if iface.startswith('ether'))

            missing_masks = []
            for mask in expected_masks:
                mask_count = len([s for s in found_masks if s == str(mask)])
                if mask_count == 0:
                    missing_masks.append(mask)

            if missing_masks:
                errors.append(f"Missing subnet masks on ether interfaces: /{', /'.join(map(str, missing_masks))}")
            else:
                results.append({
                    'passed': True,
                    'message': f"Found expected subnet masks: /{', /'.join(map(str, expected_masks))}"
                })

        return results, errors

    elif req_type == 'exact':
        # Exact string match
        cmd_normalized = normalize_command(requirement['command'])
        config_normalized = normalize_command(config_text)

        if cmd_normalized in config_normalized:
            return [{'passed': True, 'message': 'Command found correctly'}], []
        else:
            return [], [f"Missing or incorrect: {requirement['command']}"]

    elif req_type == 'pattern':
        # Regex pattern match
        pattern = requirement['pattern']
        if re.search(pattern, config_text, re.IGNORECASE):
            return [{'passed': True, 'message': requirement.get('description', 'Pattern matched')}], []
        else:
            return [], [f"Missing or incorrect: {requirement.get('description', pattern)}"]

    return [], ["Unknown requirement type"]

def check_device_config(config_text, device_name, expected):
    """Check if a device configuration contains all required commands"""
    results = []

    for requirement in expected['requirements']:
        req_name = requirement.get('name', 'Unnamed requirement')

        passed_checks, error_messages = check_pattern_requirement(config_text, requirement)

        if error_messages:
            # Failed - create a failed test for each error
            for error in error_messages:
                results.append({
                    "name": f"{device_name}: {req_name}",
                    "score": 0.0,
                    "max_score": 1.0,
                    "status": "failed",
                    "output": error
                })
        else:
            # Passed - create a passed test
            message = passed_checks[0]['message'] if passed_checks else 'Requirement met'
            results.append({
                "name": f"{device_name}: {req_name}",
                "score": 1.0,
                "max_score": 1.0,
                "status": "passed",
                "output": message
            })

    return results

def main():
    submission_dir = '/autograder/submission'
    results_dir = '/autograder/results'

    # Load expected configurations
    try:
        expected_configs = load_expected_configs()
    except Exception as e:
        # If config file cannot be loaded, fail gracefully
        results = {
            "score": 0,
            "output": f"Autograder configuration error: {str(e)}",
            "tests": []
        }
        os.makedirs(results_dir, exist_ok=True)
        with open(os.path.join(results_dir, 'results.json'), 'w') as f:
            json.dump(results, f, indent=2)
        return

    # Initialize results
    all_tests = []
    total_score = 0
    max_score = 0

    # Check for each device configuration file
    for device, expected in expected_configs.items():
        config_file = os.path.join(submission_dir, f'{device}-config.txt')

        if not os.path.exists(config_file):
            num_requirements = len(expected.get('requirements', []))
            all_tests.append({
                "name": f"{device}: Configuration file",
                "score": 0.0,
                "max_score": num_requirements,
                "status": "failed",
                "output": f"Missing configuration file: {device}-config.txt"
            })
            max_score += num_requirements
            continue

        # Read and check configuration
        with open(config_file, 'r') as f:
            config_content = f.read()

        device_tests = check_device_config(
            config_content,
            device,
            expected
        )

        all_tests.extend(device_tests)
        total_score += sum(t['score'] for t in device_tests)
        max_score += len(device_tests)

    # Scale score to 10 points
    if max_score > 0:
        scaled_score = round((total_score / max_score) * 10, 2)
    else:
        scaled_score = 0

    # Create results.json
    results = {
        "score": scaled_score,
        "execution_time": 1,
        "output": f"Checked {len(all_tests)} configuration items across {len(expected_configs)} devices",
        "tests": all_tests,
        "output_format": "text"
    }

    # Write results
    os.makedirs(results_dir, exist_ok=True)
    with open(os.path.join(results_dir, 'results.json'), 'w') as f:
        json.dump(results, f, indent=2)

if __name__ == '__main__':
    main()
