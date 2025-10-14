# Usage Examples

This document provides comprehensive examples of using the Docker Certificate Action in various scenarios.

## Basic Examples

### 1. Install Certificate from Local File

```yaml
- name: Install company CA certificate
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: 'certs/company-ca.crt'
```

### 2. Install Certificate from URL

```yaml
- name: Install certificate from PKI server
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: 'https://pki.company.com/certs/root-ca.crt'
    certificate-name: 'company-root-ca.crt'
```

### 3. Install Certificate from GitHub Secret

```yaml
- name: Install certificate from secret
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: 'inline'
    certificate-body: ${{ secrets.CUSTOM_CA_CERT }}
    certificate-name: 'custom-ca.crt'
```

## Advanced Examples

### 4. Multiple Certificates (Certificate Chain)

```yaml
- name: Install root CA
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: 'certs/root-ca.crt'
    certificate-name: 'root-ca.crt'

- name: Install intermediate CA
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: 'certs/intermediate-ca.crt'
    certificate-name: 'intermediate-ca.crt'
```

### 5. With Debug Output

```yaml
- name: Install certificate with debugging
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: 'certs/debug-ca.crt'
    debug: true
```

## Complete Workflow Examples

### 6. Build and Push to Private Registry

```yaml
name: Build Docker Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Install custom CA certificate
        uses: ravensorb/actions/docker-certificate@v1
        with:
          certificate-source: 'inline'
          certificate-body: ${{ secrets.COMPANY_CA_CERT }}
          certificate-name: 'company-ca.crt'
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to registry
        uses: docker/login-action@v3
        with:
          registry: registry.company.com
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: registry.company.com/myapp:latest
```

### 7. Multi-Platform Build with Custom Certificate

```yaml
name: Multi-Platform Build

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Install certificate from URL
        uses: ravensorb/actions/docker-certificate@v1
        with:
          certificate-source: 'https://pki.internal.net/ca/root.crt'
          debug: true
      
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Harbor
        uses: docker/login-action@v3
        with:
          registry: harbor.internal.net
          username: ${{ secrets.HARBOR_USERNAME }}
          password: ${{ secrets.HARBOR_PASSWORD }}
      
      - name: Build and push multi-platform
        uses: docker/build-push-action@v6
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: |
            harbor.internal.net/myapp:${{ github.ref_name }}
            harbor.internal.net/myapp:latest
```

### 8. Python Package Build with Internal PyPI

```yaml
name: Build Python Package

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Install custom CA for internal PyPI
        uses: ravensorb/actions/docker-certificate@v1
        with:
          certificate-source: ${{ secrets.PYPI_CA_CERT }}
          certificate-name: 'internal-pypi-ca.crt'
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies from internal PyPI
        run: |
          pip install --index-url https://pypi.internal.company.com/simple/ -r requirements.txt
      
      - name: Build package
        run: |
          python -m build
```

### 9. Node.js Build with Internal npm Registry

```yaml
name: Build Node.js App

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Install custom CA for internal npm
        uses: ravensorb/actions/docker-certificate@v1
        with:
          certificate-source: 'https://pki.company.com/npm-ca.crt'
      
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://npm.internal.company.com'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
```

### 10. Docker Build with Internal Resources

```yaml
name: Docker Build with Internal Resources

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Install custom CA certificate
        uses: ravensorb/actions/docker-certificate@v1
        with:
          certificate-source: 'certs/internal-ca.crt'
      
      - name: Build image (can access internal resources in Dockerfile)
        uses: docker/build-push-action@v6
        with:
          context: .
          push: false
          tags: myapp:test
          # Dockerfile can now access:
          # - Internal package repositories
          # - Internal file servers
          # - Internal APIs
          # - etc.
```

## Troubleshooting Examples

### 11. Verify Certificate Installation

```yaml
- name: Install certificate
  uses: ravensorb/actions/docker-certificate@v1
  id: install-cert
  with:
    certificate-source: 'certs/ca.crt'

- name: Verify certificate was installed
  run: |
    echo "Certificate installed at: ${{ steps.install-cert.outputs.certificate-path }}"
    echo "Certificate name: ${{ steps.install-cert.outputs.certificate-name }}"
    
    # Check if certificate exists
    ls -la ${{ steps.install-cert.outputs.certificate-path }}
    
    # Check certificate details
    openssl x509 -in ${{ steps.install-cert.outputs.certificate-path }} -noout -subject -issuer -dates
    
    # Verify certificate is in CA bundle
    openssl verify -CApath /etc/ssl/certs ${{ steps.install-cert.outputs.certificate-path }}
```

### 12. Test Registry Connection After Installation

```yaml
- name: Install certificate
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: ${{ secrets.REGISTRY_CA }}
    certificate-name: 'registry-ca.crt'
    debug: true

- name: Test registry connectivity
  run: |
    echo "Testing connection to registry.company.com..."
    curl -v https://registry.company.com/v2/
    
    echo "Testing Docker registry API..."
    docker login registry.company.com -u ${{ secrets.REGISTRY_USER }} -p ${{ secrets.REGISTRY_PASS }}
    docker pull registry.company.com/test/hello-world || echo "Pull failed (image may not exist)"
```

## Integration with Existing Workflows

### 13. Replace Existing Certificate Installation

**Before:**
```yaml
- name: Copy custom certificate
  if: ${{ env.CUSTOM_CERTIFICATE }}
  run: |
    if [ -f /certs/${{ env.CUSTOM_CERTIFICATE }} ]; then
      mkdir -p /usr/local/share/ca-certificates
      cp /certs/${{ env.CUSTOM_CERTIFICATE }} /usr/local/share/ca-certificates/
      update-ca-certificates
    fi
```

**After:**
```yaml
- name: Install custom certificate
  if: ${{ env.CUSTOM_CERTIFICATE }}
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: '/certs/${{ env.CUSTOM_CERTIFICATE }}'
```

### 14. Conditional Certificate Installation

```yaml
- name: Install certificate (production only)
  if: github.ref == 'refs/heads/main'
  uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: 'inline'
    certificate-body: ${{ secrets.PROD_CA_CERT }}
    certificate-name: 'prod-ca.crt'
```

### 15. Dynamic Certificate from Environment

```yaml
env:
  CERT_URL: 'https://pki.company.com/certs/current-ca.crt'
  
jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Install certificate from environment URL
        uses: ravensorb/actions/docker-certificate@v1
        with:
          certificate-source: ${{ env.CERT_URL }}
```

## Real-World Use Cases

### 16. Corporate Infrastructure Build

```yaml
name: Corporate Build Pipeline

on:
  push:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      # Install corporate CA certificate
      - name: Install corporate CA
        uses: ravensorb/actions/docker-certificate@v1
        with:
          certificate-source: 'inline'
          certificate-body: ${{ secrets.CORPORATE_CA_CERT }}
          certificate-name: 'corporate-ca.crt'
      
      # Now all internal services work automatically
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to internal registry
        uses: docker/login-action@v3
        with:
          registry: harbor.corp.internal
          username: ${{ secrets.HARBOR_USER }}
          password: ${{ secrets.HARBOR_PASS }}
      
      - name: Build with access to all internal resources
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            harbor.corp.internal/myteam/myapp:${{ github.sha }}
            harbor.corp.internal/myteam/myapp:latest
          # Dockerfile can now access:
          # - harbor.corp.internal (registry)
          # - pypi.corp.internal (Python packages)
          # - npm.corp.internal (Node packages)
          # - maven.corp.internal (Java packages)
          # - Any other internal HTTPS service
```
