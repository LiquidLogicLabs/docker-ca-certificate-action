# Docker Certificate GitHub Action

A GitHub Action that installs custom SSL/TLS certificates into the CI/CD runner environment, enabling Docker and other tools to work with private registries and internal resources that use custom certificate authorities.

## Features

- 📁 **Multiple Input Methods**: Local file, URL, or inline certificate content
- 🔒 **System Integration**: Installs to system CA store and runs `update-ca-certificates`
- ✅ **Simple**: Just install the cert - Docker will automatically trust it
- 🛡️ **Robust**: Comprehensive error handling and validation
- 🔄 **Idempotent**: Safe to run multiple times

## Usage

### Quick Start

```yaml
- name: Install custom certificate
  uses: ravensorb/docker-certificate-action@v1
  with:
    certificate-source: 'certs/company-ca.crt'
```

### From URL

```yaml
- name: Install certificate from URL
  uses: ravensorb/docker-certificate-action@v1
  with:
    certificate-source: 'https://pki.company.com/ca.crt'
```

### From GitHub Secret

```yaml
- name: Install certificate from secret
  uses: ravensorb/docker-certificate-action@v1
  with:
    certificate-source: 'inline'
    certificate-body: ${{ secrets.CUSTOM_CA_CERT }}
    certificate-name: 'company-ca.crt'
```

📚 **More examples:** See [docs/EXAMPLES.md](docs/EXAMPLES.md)

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `certificate-source` | Certificate source: file path, URL, or 'inline' | Yes | - |
| `certificate-body` | Certificate content (required when source is 'inline') | No | - |
| `certificate-name` | Name for certificate file | No | Auto-generated |
| `debug` | Enable debug output | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `certificate-path` | Path where certificate was installed |

## How It Works

1. **Acquires Certificate**: Downloads/reads certificate from specified source
2. **Validates Format**: Ensures certificate is valid PEM format
3. **System Installation**: Copies to `/usr/local/share/ca-certificates/` and runs `update-ca-certificates`
4. **Reports Success**: Outputs installation path and status

Once installed, the certificate is trusted by:
- ✅ Docker (push/pull from registries with custom certs)
- ✅ curl, wget, and other HTTP clients
- ✅ pip, npm, apt, and other package managers
- ✅ Git operations over HTTPS
- ✅ Any tool that uses the system CA store

## Requirements

- Ubuntu runner (tested on ubuntu-22.04)
- Appropriate permissions to write to system directories

📋 **Full requirements:** See [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md)

## Versioning

This action follows [Semantic Versioning](https://semver.org/).

**Recommended usage:**
```yaml
uses: ravensorb/docker-certificate-action@v1  # Gets latest v1.x.x
```

## Documentation

- 📖 [Examples](docs/EXAMPLES.md) - Comprehensive usage examples
- 🔧 [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- 📋 [Requirements](docs/REQUIREMENTS.md) - Detailed requirements

### For Maintainers

- 🧪 [Local Testing](docs/LOCAL-TESTING.md) - Test with act before pushing
- 🚀 [Quick Release Guide](docs/QUICK-RELEASE.md) - One-command releases
- 📦 [Publishing Guide](docs/PUBLISH.md) - Publishing to GitHub
- ⚙️ [Release Setup](docs/RELEASE-SETUP.md) - Release automation setup
- 🧪 [Testing Releases](docs/TEST-RELEASE.md) - Testing before release

## Troubleshooting

Having issues? Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for common problems and solutions.

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

[MIT License](LICENSE) - see LICENSE file for details.

