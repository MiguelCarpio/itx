#!/usr/bin/env python3
"""
Test script to simulate Gradescope autograder environment
"""
import os
import sys
import shutil
import json

# Set up the simulated Gradescope environment
AUTOGRADER_ROOT = "/tmp/test_autograder"
SOURCE_DIR = os.path.join(AUTOGRADER_ROOT, "source")
SUBMISSION_DIR = os.path.join(AUTOGRADER_ROOT, "submission")
RESULTS_DIR = os.path.join(AUTOGRADER_ROOT, "results")

def setup_environment():
    """Create the Gradescope directory structure"""
    # Clean up if exists
    if os.path.exists(AUTOGRADER_ROOT):
        shutil.rmtree(AUTOGRADER_ROOT)

    # Create directories
    os.makedirs(SOURCE_DIR)
    os.makedirs(SUBMISSION_DIR)
    os.makedirs(RESULTS_DIR)

    # Copy autograder files to source
    project_root = "/home/miguel/CLAUDE/itx"
    shutil.copy(
        os.path.join(project_root, "autograder", "verify_config.py"),
        os.path.join(SOURCE_DIR, "verify_config.py")
    )
    shutil.copy(
        os.path.join(project_root, "autograder", "expected_configs.json"),
        os.path.join(SOURCE_DIR, "expected_configs.json")
    )

    # Copy test submission files (HQ, MPLS, and Switch configs)
    for filename in ["HQ-1-config.txt", "HQ-2-config.txt", "HQ-3-config.txt",
                     "CE-1-config.txt", "PE-1-config.txt", "P-1-config.txt",
                     "P-2-config.txt", "PE-2-config.txt", "CE-2-config.txt",
                     "SD-1-config.txt", "SD-2-config.txt", "SA-1-config.txt", "SA-2-config.txt"]:
        src = os.path.join(project_root, "test_submission", filename)
        dst = os.path.join(SUBMISSION_DIR, filename)
        if os.path.exists(src):
            shutil.copy(src, dst)

    print(f"✓ Created test environment at {AUTOGRADER_ROOT}")
    print(f"  - Source: {SOURCE_DIR}")
    print(f"  - Submission: {SUBMISSION_DIR}")
    print(f"  - Results: {RESULTS_DIR}")
    print()

def run_autograder():
    """Run the autograder in the simulated environment"""
    # Change to autograder root
    original_dir = os.getcwd()

    # Read and modify the verify_config.py to use our test paths
    with open(os.path.join(SOURCE_DIR, "verify_config.py"), 'r') as f:
        code = f.read()

    # Replace hardcoded paths with our test paths
    code = code.replace("submission_dir = '/autograder/submission'", f"submission_dir = '{SUBMISSION_DIR}'")
    code = code.replace("results_dir = '/autograder/results'", f"results_dir = '{RESULTS_DIR}'")
    code = code.replace("os.path.join(os.path.dirname(__file__), 'expected_configs.json')",
                       f"'{os.path.join(SOURCE_DIR, 'expected_configs.json')}'")

    # Write modified version
    test_script = os.path.join(AUTOGRADER_ROOT, "verify_config_test.py")
    with open(test_script, 'w') as f:
        f.write(code)

    # Add source to Python path
    sys.path.insert(0, SOURCE_DIR)

    # Import and run the modified autograder
    import importlib.util
    spec = importlib.util.spec_from_file_location("verify_config_test", test_script)
    verify_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(verify_module)

    print("Running autograder...")
    print("=" * 60)
    verify_module.main()
    print("=" * 60)
    print()

    # Restore directory
    os.chdir(original_dir)

def display_results():
    """Display the results.json file"""
    results_file = os.path.join(RESULTS_DIR, "results.json")

    if not os.path.exists(results_file):
        print("ERROR: results.json not found!")
        return

    with open(results_file, 'r') as f:
        results = json.load(f)

    print("AUTOGRADER RESULTS")
    print("=" * 60)
    print(f"Score: {results['score']} / 10")
    print(f"Output: {results['output']}")
    print()

    print("INDIVIDUAL TESTS:")
    print("-" * 60)

    current_device = None
    for test in results['tests']:
        device = test['name'].split(':')[0]
        if device != current_device:
            print()
            print(f"[{device}]")
            current_device = device

        status_symbol = "✓" if test['status'] == "passed" else "✗"
        test_name = ':'.join(test['name'].split(':')[1:]).strip()

        print(f"  {status_symbol} {test_name}")
        if test['status'] == "failed":
            print(f"    → {test['output']}")

    print()
    print("=" * 60)

    # Save formatted output
    output_file = "/home/miguel/CLAUDE/itx/test_results.txt"
    with open(output_file, 'w') as f:
        f.write(f"Score: {results['score']}\n")
        f.write(f"Output: {results['output']}\n\n")
        f.write(json.dumps(results, indent=2))

    print(f"\n✓ Full results saved to: {output_file}")

if __name__ == "__main__":
    setup_environment()
    run_autograder()
    display_results()
