#!/bin/bash
# install-dependencies.sh - Install all required dependencies for the Docker Certificate Action
# This script checks for and installs dependencies if they are not already present

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${CYAN}[DEBUG]${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get the operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            echo "ubuntu"
        elif command_exists yum; then
            echo "centos"
        elif command_exists dnf; then
            echo "fedora"
        elif command_exists pacman; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Install Node.js and npm
install_nodejs() {
    local os="$1"
    log_info "Installing Node.js and npm..."
    
    case "$os" in
        "ubuntu")
            if ! command_exists curl; then
                log_info "Installing curl..."
                sudo apt-get update && sudo apt-get install -y curl
            fi
            
            # Install NodeSource repository
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "centos")
            if ! command_exists curl; then
                log_info "Installing curl..."
                sudo yum install -y curl
            fi
            
            # Install NodeSource repository
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        "fedora")
            if ! command_exists curl; then
                log_info "Installing curl..."
                sudo dnf install -y curl
            fi
            
            # Install NodeSource repository
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo dnf install -y nodejs
            ;;
        "arch")
            sudo pacman -S --noconfirm nodejs npm
            ;;
        "macos")
            if command_exists brew; then
                brew install node
            else
                log_error "Homebrew not found. Please install Homebrew first: https://brew.sh/"
                return 1
            fi
            ;;
        *)
            log_error "Unsupported operating system: $os"
            log_info "Please install Node.js manually from https://nodejs.org/"
            return 1
            ;;
    esac
    
    log_info "Node.js version: $(node --version)"
    log_info "npm version: $(npm --version)"
}

# Install system dependencies
install_system_deps() {
    local os="$1"
    log_info "Installing system dependencies..."
    
    case "$os" in
        "ubuntu")
            sudo apt-get update
            sudo apt-get install -y openssl ca-certificates curl
            ;;
        "centos")
            sudo yum install -y openssl ca-certificates curl
            ;;
        "fedora")
            sudo dnf install -y openssl ca-certificates curl
            ;;
        "arch")
            sudo pacman -S --noconfirm openssl ca-certificates curl
            ;;
        "macos")
            if command_exists brew; then
                brew install openssl curl
            else
                log_warn "Homebrew not found. Please install openssl and curl manually."
            fi
            ;;
        *)
            log_warn "Unsupported operating system: $os"
            log_info "Please install openssl, ca-certificates, and curl manually"
            ;;
    esac
}

# Install act (optional)
install_act() {
    local os="$1"
    log_info "Installing act (GitHub Actions local runner)..."
    
    case "$os" in
        "ubuntu"|"centos"|"fedora"|"arch")
            # Install using the official installer
            curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
            ;;
        "macos")
            if command_exists brew; then
                brew install act
            else
                log_warn "Homebrew not found. Please install act manually: https://github.com/nektos/act"
                return 1
            fi
            ;;
        *)
            log_warn "Unsupported operating system: $os"
            log_info "Please install act manually: https://github.com/nektos/act"
            return 1
            ;;
    esac
    
    log_info "act version: $(act --version)"
}

# Install npm dependencies
install_npm_deps() {
    log_info "Installing npm dependencies..."
    
    if [ -f "package.json" ]; then
        npm install
        log_info "npm dependencies installed successfully"
    else
        log_warn "package.json not found in current directory"
        log_info "Please run this script from the project root directory"
        return 1
    fi
}

# Verify Node.js version
verify_nodejs_version() {
    local required_version="16.0.0"
    local current_version
    
    if ! command_exists node; then
        log_error "Node.js is not installed"
        return 1
    fi
    
    current_version=$(node --version | sed 's/v//')
    
    # Compare versions (basic check)
    if [[ "$(printf '%s\n' "$required_version" "$current_version" | sort -V | head -n1)" == "$required_version" ]]; then
        log_info "Node.js version $current_version meets requirement (>= $required_version)"
        return 0
    else
        log_error "Node.js version $current_version does not meet requirement (>= $required_version)"
        return 1
    fi
}

# Main installation function
main() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🔧 Docker Certificate Action - Dependency Installer${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Detect operating system
    OS=$(detect_os)
    log_info "Detected operating system: $OS"
    echo ""
    
    # Check for sudo access
    if ! sudo -n true 2>/dev/null; then
        log_warn "This script requires sudo access for system-level installations"
        log_info "You may be prompted for your password"
    fi
    
    # Install system dependencies
    log_info "Checking system dependencies..."
    INSTALL_SYSTEM_DEPS=false
    
    if ! command_exists openssl; then
        log_warn "openssl not found - will install"
        INSTALL_SYSTEM_DEPS=true
    else
        log_info "✓ openssl is installed ($(openssl version))"
    fi
    
    if ! command_exists curl; then
        log_warn "curl not found - will install"
        INSTALL_SYSTEM_DEPS=true
    else
        log_info "✓ curl is installed ($(curl --version | head -n1))"
    fi
    
    if [ "$INSTALL_SYSTEM_DEPS" = true ]; then
        install_system_deps "$OS"
    fi
    echo ""
    
    # Check Node.js
    log_info "Checking Node.js..."
    if ! command_exists node; then
        log_warn "Node.js not found - will install"
        install_nodejs "$OS"
    else
        log_info "✓ Node.js is installed ($(node --version))"
        if ! verify_nodejs_version; then
            log_warn "Node.js version does not meet requirements - will reinstall"
            install_nodejs "$OS"
        fi
    fi
    echo ""
    
    # Check npm
    log_info "Checking npm..."
    if ! command_exists npm; then
        log_error "npm not found - this should have been installed with Node.js"
        return 1
    else
        log_info "✓ npm is installed ($(npm --version))"
    fi
    echo ""
    
    # Install npm dependencies
    log_info "Checking npm dependencies..."
    if [ -f "package.json" ]; then
        if [ ! -d "node_modules" ] || [ ! -f "package-lock.json" ]; then
            log_warn "npm dependencies not installed - will install"
            install_npm_deps
        else
            log_info "✓ npm dependencies are installed"
        fi
    else
        log_warn "package.json not found - skipping npm dependency installation"
    fi
    echo ""
    
    # Optional: Install act
    log_info "Checking act (optional)..."
    if ! command_exists act; then
        log_warn "act not found - will install (optional for local testing)"
        if install_act "$OS"; then
            log_info "✓ act installed successfully"
        else
            log_warn "Failed to install act - you can install it manually later"
        fi
    else
        log_info "✓ act is installed ($(act --version))"
    fi
    echo ""
    
    # Final verification
    log_info "Verifying all dependencies..."
    echo ""
    
    local all_good=true
    
    # Check required dependencies
    if ! command_exists node; then
        log_error "❌ Node.js is missing"
        all_good=false
    else
        log_info "✅ Node.js: $(node --version)"
    fi
    
    if ! command_exists npm; then
        log_error "❌ npm is missing"
        all_good=false
    else
        log_info "✅ npm: $(npm --version)"
    fi
    
    if ! command_exists openssl; then
        log_error "❌ openssl is missing"
        all_good=false
    else
        log_info "✅ openssl: $(openssl version)"
    fi
    
    if ! command_exists curl; then
        log_error "❌ curl is missing"
        all_good=false
    else
        log_info "✅ curl: $(curl --version | head -n1)"
    fi
    
    # Check optional dependencies
    if command_exists act; then
        log_info "✅ act: $(act --version)"
    else
        log_warn "⚠️  act: not installed (optional)"
    fi
    
    # Check npm dependencies
    if [ -f "package.json" ] && [ -d "node_modules" ]; then
        log_info "✅ npm dependencies: installed"
    else
        log_warn "⚠️  npm dependencies: not installed"
    fi
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ "$all_good" = true ]; then
        echo -e "${GREEN}🎉 All required dependencies are installed successfully!${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Run tests: npm test"
        echo "  2. Test locally: ./act-build.sh"
        echo "  3. Build and release: npm run release"
    else
        echo -e "${RED}❌ Some dependencies are missing. Please check the errors above.${NC}"
        echo ""
        echo "Manual installation options:"
        echo "  Node.js: https://nodejs.org/"
        echo "  act: https://github.com/nektos/act"
        return 1
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Run main function
main "$@"
