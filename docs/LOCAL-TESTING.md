# Local Testing with Act

Test this GitHub Action locally using [act](https://github.com/nektos/act) before pushing to GitHub.

## Installing Act

### macOS
```bash
brew install act
```

### Linux
```bash
# Download latest release
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Windows (WSL)
```bash
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

## Basic Testing

### 1. Test the Existing Test Workflow

```bash
# Run the test workflow
act -W .github/workflows/test.yml

# Run specific job
act -W .github/workflows/test.yml -j test-local-file

# List all jobs without running
act -W .github/workflows/test.yml -l
```

### 2. Create a Simple Test Workflow

Create `.github/workflows/act-test.yml`:

```yaml
name: Act Local Test

on: [push]

jobs:
  test-local:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Create test certificate
        run: |
          mkdir -p test-certs
          openssl req -x509 -newkey rsa:2048 -keyout test-certs/test-key.pem \
            -out test-certs/test-ca.crt -days 365 -nodes \
            -subj "/C=US/ST=Test/L=Test/O=Test/CN=test.local"
      
      - name: Test certificate installation
        uses: ./  # This references the local action
        with:
          certificate-source: 'test-certs/test-ca.crt'
          debug: true
      
      - name: Verify installation
        run: |
          echo "=== Checking installed certificate ==="
          ls -la /usr/local/share/ca-certificates/
          
          if [ -f /usr/local/share/ca-certificates/custom-ca-*.crt ]; then
            echo "✓ Certificate installed successfully"
            openssl x509 -in /usr/local/share/ca-certificates/custom-ca-*.crt -noout -subject
          else
            echo "✗ Certificate not found"
            exit 1
          fi
```

### 3. Run the Test

```bash
# Run the test workflow
act -W .github/workflows/act-test.yml

# With verbose output
act -W .github/workflows/act-test.yml -v
```

## Testing Different Scenarios

### Test with Local File

```bash
# Create test certificate first
mkdir -p test-certs
openssl req -x509 -newkey rsa:2048 -keyout test-certs/test-key.pem \
  -out test-certs/test-ca.crt -days 365 -nodes \
  -subj "/C=US/ST=Test/L=Test/O=Test/CN=test.local"

# Run test
act -W .github/workflows/test.yml -j test-local-file
```

### Test with URL

```bash
# Run URL test
act -W .github/workflows/test.yml -j test-url
```

### Test with Inline Content

```bash
# Run inline test
act -W .github/workflows/test.yml -j test-inline
```

## Act Configuration

### Create `.actrc` File

In your repository root, create `.actrc`:

```bash
# Use larger Docker image with more tools
-P ubuntu-latest=catthehacker/ubuntu:full-latest

# Bind mount for certificates (if needed)
--bind

# Verbose output
-v
```

### Use Environment Variables

Create `.secrets` file for testing with secrets:

```env
CUSTOM_CA_CERT=-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAKL0UG+mRHGfMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
...
-----END CERTIFICATE-----
```

Run with secrets:
```bash
act --secret-file .secrets
```

## Common Act Issues & Solutions

### Issue: Permission Denied

**Error:**
```
Error: Permission denied when installing certificate
```

**Solution:**
Act runs in Docker with limited permissions. Use `--privileged`:

```bash
act -W .github/workflows/test.yml --privileged
```

### Issue: Action Not Found

**Error:**
```
Error: Unable to resolve action ./
```

**Solution:**
Ensure you're in the repository root:

```bash
cd /home/ravenwolf.org/sanderson/source/git/ravensorb/actions/docker-certificate
act -W .github/workflows/test.yml
```

### Issue: Docker Image Too Small

**Error:**
```
bash: update-ca-certificates: command not found
```

**Solution:**
Use a fuller Ubuntu image:

```bash
act -P ubuntu-latest=catthehacker/ubuntu:full-latest
```

Or add to `.actrc`:
```
-P ubuntu-latest=catthehacker/ubuntu:full-latest
```

### Issue: Secrets Not Available

**Error:**
```
Error: certificate-body is required
```

**Solution:**
Use `--secret-file`:

```bash
act --secret-file .secrets
```

## Quick Test Script

Create `test-local.sh`:

```bash
#!/bin/bash
# Quick local test script

set -e

echo "🧪 Testing Docker Certificate Action locally with act"
echo ""

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "❌ act is not installed"
    echo "Install: brew install act (macOS) or see https://github.com/nektos/act"
    exit 1
fi

echo "✓ act is installed"
echo ""

# Create test certificate if not exists
if [ ! -f test-certs/test-ca.crt ]; then
    echo "📝 Creating test certificate..."
    mkdir -p test-certs
    openssl req -x509 -newkey rsa:2048 -keyout test-certs/test-key.pem \
      -out test-certs/test-ca.crt -days 365 -nodes \
      -subj "/C=US/ST=Test/L=Test/O=Test/CN=test.local" 2>/dev/null
    echo "✓ Test certificate created"
    echo ""
fi

# Run tests
echo "🚀 Running local tests..."
echo ""

# Test 1: Local file
echo "Test 1: Local file installation"
act -W .github/workflows/test.yml -j test-local-file --privileged

echo ""
echo "✅ All tests passed!"
```

Make it executable:
```bash
chmod +x test-local.sh
./test-local.sh
```

## Testing Specific Features

### Test Certificate Validation

Create `test-validation.yml`:

```yaml
name: Test Validation

on: [push]

jobs:
  test-invalid-cert:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Test with invalid certificate (should fail)
        uses: ./
        continue-on-error: true
        id: test
        with:
          certificate-source: 'inline'
          certificate-body: 'not a valid certificate'
      
      - name: Check it failed
        if: steps.test.outcome == 'failure'
        run: echo "✓ Correctly rejected invalid certificate"
```

Run it:
```bash
act -W .github/workflows/test-validation.yml
```

### Test Error Handling

```yaml
name: Test Error Handling

on: [push]

jobs:
  test-missing-file:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Test missing file (should fail)
        uses: ./
        continue-on-error: true
        id: test
        with:
          certificate-source: 'nonexistent.crt'
      
      - name: Verify error was caught
        if: steps.test.outcome == 'failure'
        run: echo "✓ Error correctly handled"
```

## Debugging with Act

### Enable Debug Output

```bash
# Enable debug logging
act -W .github/workflows/test.yml -v --verbose
```

### Interactive Debugging

```bash
# Drop into shell on failure
act -W .github/workflows/test.yml --shell bash
```

### Check Environment

Create `debug.yml`:

```yaml
name: Debug Environment

on: [push]

jobs:
  debug:
    runs-on: ubuntu-latest
    steps:
      - name: Check environment
        run: |
          echo "=== System Info ==="
          uname -a
          
          echo "=== Disk Space ==="
          df -h
          
          echo "=== Certificates ==="
          ls -la /usr/local/share/ca-certificates/ || echo "Directory not found"
          
          echo "=== OpenSSL Version ==="
          openssl version
```

Run it:
```bash
act -W .github/workflows/debug.yml
```

## Complete Test Suite

Run all tests at once:

```bash
#!/bin/bash
# Run complete test suite locally

echo "Running complete test suite with act..."

# Test 1: Local file
echo "1. Testing local file..."
act -W .github/workflows/test.yml -j test-local-file --privileged

# Test 2: URL
echo "2. Testing URL download..."
act -W .github/workflows/test.yml -j test-url --privileged

# Test 3: Inline
echo "3. Testing inline content..."
act -W .github/workflows/test.yml -j test-inline --privileged

echo ""
echo "✅ All tests completed!"
```

## Best Practices

1. **Always use `--privileged`** for this action (needs to modify system)
2. **Test on clean state** - stop and remove Docker containers between runs
3. **Use `.actrc`** for consistent configuration
4. **Create test certificates** before running tests
5. **Check Docker logs** if something fails: `docker logs <container>`

## Cleaning Up

After testing:

```bash
# Remove test certificates
rm -rf test-certs/

# Clean up Docker containers
docker ps -a | grep act | awk '{print $1}' | xargs docker rm -f

# Clean up Docker images (optional)
docker images | grep act | awk '{print $3}' | xargs docker rmi
```

## Next Steps

After local testing passes:
1. Push to GitHub
2. Run actual GitHub Actions
3. Compare results
4. Create release with `./bump-version.sh`

## Useful Act Commands

```bash
# List workflows
act -l

# List jobs in specific workflow
act -W .github/workflows/test.yml -l

# Run specific job
act -W .github/workflows/test.yml -j test-local-file

# Dry run (don't execute)
act -W .github/workflows/test.yml -n

# Use specific platform
act -P ubuntu-latest=ubuntu:22.04

# Rebuild Docker image
act --pull

# Keep containers after run
act --reuse

# Bind mount workspace
act --bind
```

## Resources

- [Act Documentation](https://github.com/nektos/act)
- [Act Runner Images](https://github.com/catthehacker/docker_images)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

