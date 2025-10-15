# Docker Certificate Action - Requirements

## Overview
A GitHub action that installs custom certificates into the CI/CD runner environment's system CA store.

## Purpose
Enable Docker and other tools to work with private registries or internal resources that use custom SSL/TLS certificates by installing the certificate into the system trust store and running `update-ca-certificates`.

## Reference Implementation
Based on the "Copy custom certificate" step from existing docker-build.yaml workflow (lines 129-148).

## Core Requirements

### Input Methods
The action must support three methods for providing the certificate:

1. **Local File Path** - Reference a certificate file in the repository
   - Input: Path relative to repository root
   - Example: `certs/company-ca.crt`

2. **URL** - Download certificate from a web location
   - Input: HTTP or HTTPS URL
   - Example: `https://example.com/certs/ca.crt`
   - Should support both http:// and https:// protocols

3. **Certificate Body** - Provide certificate content directly
   - Input: Full certificate text (PEM format)
   - Example: Multi-line string containing certificate

### Certificate Installation
The action installs the certificate to the **System CA Store**:

- **Location**: `/usr/local/share/ca-certificates/`
- **Action**: Copy certificate file with specified or auto-generated name
- **Follow-up**: Run `update-ca-certificates` to update system trust store

Once the system trusts the certificate, all tools (Docker, curl, wget, pip, npm, git, etc.) automatically trust it.

### Inputs

- `certificate-source`: The certificate source (file path, URL, or 'inline')
- `certificate-body`: The certificate content (when source is 'inline')
- `certificate-name`: Name for the certificate file (defaults to auto-generated)
- `debug`: Enable verbose debug output (default: false)

### Behavior

- Should create directories if they don't exist
- Should handle errors gracefully with clear messages
- Should support verbose/debug output mode
- Should validate certificate format before installation
- Should be idempotent (safe to run multiple times)

### Error Handling

- File not found (local file mode)
- URL not accessible (URL mode)
- Invalid certificate format
- Permission errors during installation
- Missing required inputs

### Success Criteria

1. Certificate successfully installed to system CA store
2. `update-ca-certificates` runs without errors  
3. Docker can pull from/push to registries using custom certificate
4. Other tools (pip, npm, curl, etc.) can access internal resources with custom certificates
5. Action can be used in multiple build workflows

## Use Cases

1. **Private Docker Registry**: Install corporate CA to pull/push images
2. **Internal Resources**: Access internal URLs during build (pip, npm, etc.)
3. **Development Environments**: Support self-signed certificates in test pipelines
4. **Security Compliance**: Use organization-specific certificate authorities

## Outputs

- `certificate-path`: Path where certificate was installed
- `certificate-fingerprint`: SHA256 fingerprint of installed certificate (optional)

## Example Usage

```yaml
- name: Install custom certificate
  uses: LiquidLogicLabs/docker-ca-certificate-action@v1
  with:
    certificate-source: 'certs/company-ca.crt'
```

```yaml
- name: Install certificate from URL
  uses: LiquidLogicLabs/docker-ca-certificate-action@v1
  with:
    certificate-source: 'https://pki.company.com/ca.crt'
```

```yaml
- name: Install certificate from secret
  uses: LiquidLogicLabs/docker-ca-certificate-action@v1
  with:
    certificate-source: 'inline'
    certificate-body: ${{ secrets.CUSTOM_CA_CERT }}
```

