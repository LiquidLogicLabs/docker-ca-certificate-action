#!/bin/bash
set -e

# Enable debug mode if requested
if [ "$INPUT_DEBUG" = "true" ]; then
    set -x
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Validate required inputs
if [ -z "$INPUT_CERTIFICATE_SOURCE" ]; then
    log_error "certificate-source is required"
    exit 1
fi

# Determine certificate name
CERT_NAME="$INPUT_CERTIFICATE_NAME"
if [ -z "$CERT_NAME" ]; then
    CERT_NAME="custom-ca-$(date +%s).crt"
    log_info "No certificate name provided, using: $CERT_NAME"
fi

# Create temporary directory for certificate processing
TEMP_DIR=$(mktemp -d)
TEMP_CERT="$TEMP_DIR/$CERT_NAME"

log_info "Processing certificate from source: $INPUT_CERTIFICATE_SOURCE"

# Acquire certificate based on source type
if [ "$INPUT_CERTIFICATE_SOURCE" = "inline" ]; then
    # Certificate provided as inline content
    if [ -z "$INPUT_CERTIFICATE_BODY" ]; then
        log_error "certificate-body is required when certificate-source is 'inline'"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    log_info "Using inline certificate content"
    echo "$INPUT_CERTIFICATE_BODY" > "$TEMP_CERT"

elif [[ "$INPUT_CERTIFICATE_SOURCE" =~ ^https?:// ]]; then
    # Certificate provided as URL
    log_info "Downloading certificate from URL: $INPUT_CERTIFICATE_SOURCE"
    
    if ! curl -fsSL -o "$TEMP_CERT" "$INPUT_CERTIFICATE_SOURCE"; then
        log_error "Failed to download certificate from URL"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    log_info "Certificate downloaded successfully"

else
    # Certificate provided as file path
    if [ ! -f "$INPUT_CERTIFICATE_SOURCE" ]; then
        log_error "Certificate file not found: $INPUT_CERTIFICATE_SOURCE"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    log_info "Using certificate file: $INPUT_CERTIFICATE_SOURCE"
    cp "$INPUT_CERTIFICATE_SOURCE" "$TEMP_CERT"
fi

# Validate certificate format (basic check for PEM format)
if ! grep -q "BEGIN CERTIFICATE" "$TEMP_CERT"; then
    log_error "Invalid certificate format - does not appear to be a valid PEM certificate"
    rm -rf "$TEMP_DIR"
    exit 1
fi

log_info "Certificate format validated"

# Install to system CA store
log_info "Installing certificate to system CA store"

# Create directory if it doesn't exist
if [ ! -d /usr/local/share/ca-certificates ]; then
    log_info "Creating /usr/local/share/ca-certificates directory"
    sudo mkdir -p /usr/local/share/ca-certificates
fi

# Copy certificate
SYSTEM_CERT_PATH="/usr/local/share/ca-certificates/$CERT_NAME"
sudo cp "$TEMP_CERT" "$SYSTEM_CERT_PATH"
log_info "Certificate copied to: $SYSTEM_CERT_PATH"

# Update CA certificates
log_info "Updating system CA certificates"
if [ "$INPUT_DEBUG" = "true" ]; then
    sudo update-ca-certificates -v
else
    sudo update-ca-certificates
fi

log_info "System CA certificates updated successfully"

# Set output
echo "certificate-path=$SYSTEM_CERT_PATH" >> $GITHUB_OUTPUT

# Set outputs
echo "certificate-name=$CERT_NAME" >> $GITHUB_OUTPUT

# Cleanup
rm -rf "$TEMP_DIR"

log_info "✓ Certificate installation completed successfully"

