# Testing the Gradescope Autograder Locally

This guide explains how to test the autograder on your local machine before uploading to Gradescope.

## Quick Start

```bash
# Run the test with current sample submissions
python3 test_autograder.py
```

## What It Does

The `test_autograder.py` script:

1. **Simulates Gradescope environment** - Creates the same directory structure Gradescope uses:
   ```
   /tmp/test_autograder/
   ├── source/              # Your autograder files
   ├── submission/          # Student submission files
   └── results/             # Generated results.json
   ```

2. **Copies autograder files** from `autograder/` directory

3. **Copies test submissions** from `test_submission/` directory

4. **Runs the autograder** just like Gradescope would

5. **Displays results** with a formatted summary showing pass/fail for each test

6. **Saves detailed results** to `test_results.txt`

## Understanding the Output

### Console Output

```
AUTOGRADER RESULTS
============================================================
Score: 9.61 / 10
Output: Checked 128 configuration items across 13 devices

INDIVIDUAL TESTS:
------------------------------------------------------------

[HQ-1]
  ✓ System Identity
  ✓ Loopback Bridge
  ✓ IP Address ether1
  ✗ IP Address ether2
    → Missing or incorrect: IP address on ether2 with /30 mask
  ✓ OSPF Router ID
  ...
```

**Symbols:**
- `✓` - Test passed
- `✗` - Test failed (followed by error message)

### Saved Results File

Detailed JSON output is saved to `test_results.txt`:

```bash
# View detailed results
cat test_results.txt

# View with JSON formatting
cat test_results.txt | tail -n +3 | jq .
```

## Step-by-Step Testing Workflow

### 1. Test with Valid Configs

```bash
# Ensure you have valid sample configs
ls test_submission/
# Should show: HQ-1-config.txt  HQ-2-config.txt  HQ-3-config.txt
#              CE-1-config.txt  PE-1-config.txt  P-1-config.txt
#              P-2-config.txt   PE-2-config.txt  CE-2-config.txt
#              SD-1-config.txt  SD-2-config.txt  SA-1-config.txt  SA-2-config.txt

# Run test
python3 test_autograder.py
```

✅ **All tests should pass (10.0 / 10)**

### 2. Test Edge Cases

Modify configs to test specific scenarios:

```bash
# Backup originals
cp -r test_submission test_submission.backup

# Modify and test
# (edit files as needed)

# Run test
python3 test_autograder.py

# Restore originals
rm -rf test_submission
mv test_submission.backup test_submission
```

### 3. Verify Expected Configs

Make sure your `expected_configs.json` is correct:

```bash
# View current requirements
cat autograder/expected_configs.json | jq .

# Edit if needed
vim autograder/expected_configs.json

# Test again
python3 test_autograder.py
```

### 4. Package for Gradescope

Once all tests pass:

```bash
# Create the upload package
make zip-autograder

# Verify it was created
ls -lh autograder.zip
```

## Next Steps

After successful local testing:

1. ✅ Verify all expected scenarios pass/fail correctly
2. ✅ Review error messages for clarity
3. ✅ Run `make zip-autograder`
4. ✅ Upload `autograder.zip` to Gradescope
5. ✅ Test on Gradescope with sample submissions
6. ✅ Release to students

## Advanced: Custom Test Submissions

Create your own test cases:

```bash
# Create a new test directory
mkdir custom_test

# Add config files
cat > custom_test/HQ-1-config.txt << 'EOF'
# Your test configuration here
EOF

# Modify test_autograder.py to use custom_test instead of test_submission
# Or copy files to test_submission/

# Run test
python3 test_autograder.py
```

## Summary

The test autograder allows you to:
- ✅ Verify autograder logic before uploading
- ✅ Test different student scenarios
- ✅ Validate error messages are clear
- ✅ Ensure grading is fair and accurate
- ✅ Debug issues locally

**Always test locally before uploading to Gradescope!**
