# Scripts Directory

This directory contains utility scripts for the Docker Certificate Action project.

## Available Scripts

### `install-dependencies.sh`

Installs all required dependencies for the Docker Certificate Action project.

**Usage:**
```bash
./scripts/install-dependencies.sh
```

**What it installs:**
- **Node.js** (>=16.0.0) - JavaScript runtime
- **npm** - Package manager for Node.js
- **openssl** - SSL/TLS toolkit for certificate operations
- **curl** - Command-line tool for downloading files
- **ca-certificates** - System CA certificate store
- **act** (optional) - Local GitHub Actions runner for testing
- **npm dependencies** - Project-specific packages from package.json

**Supported Operating Systems:**
- Ubuntu/Debian (apt)
- CentOS/RHEL (yum)
- Fedora (dnf)
- Arch Linux (pacman)
- macOS (Homebrew)

**Features:**
- ✅ Checks if dependencies are already installed
- ✅ Only installs missing dependencies
- ✅ Cross-platform support
- ✅ Detailed logging and status reporting
- ✅ Version verification for Node.js
- ✅ Graceful error handling

**Example Output:**
```
🔧 Docker Certificate Action - Dependency Installer
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[INFO] Detected operating system: ubuntu
[INFO] ✓ openssl is installed (OpenSSL 3.4.1)
[INFO] ✓ curl is installed (curl 8.12.1)
[INFO] ✓ Node.js is installed (v22.20.0)
[INFO] ✓ npm is installed (10.9.3)
[INFO] ✓ npm dependencies are installed
[INFO] ✓ act is installed (act version 0.2.82)

🎉 All required dependencies are installed successfully!
```

## Running Scripts

Make sure scripts are executable:
```bash
chmod +x scripts/*.sh
```

Run from the project root directory:
```bash
cd /path/to/docker-ca-certificate
./scripts/install-dependencies.sh
```
