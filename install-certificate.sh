#!/bin/bash
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
    if [ "$INPUT_DEBUG" = "true" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Enable debug mode if requested
if [ "$INPUT_DEBUG" = "true" ]; then
    set -x
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🐛 DEBUG MODE ENABLED${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_debug "Environment Information:"
    log_debug "  INPUT_CERTIFICATE_SOURCE: ${INPUT_CERTIFICATE_SOURCE:-<not set>}"
    log_debug "  INPUT_CERTIFICATE_NAME: ${INPUT_CERTIFICATE_NAME:-<not set>}"
    log_debug "  INPUT_DEBUG: ${INPUT_DEBUG}"
    log_debug "  Working Directory: $(pwd)"
    log_debug "  User: $(whoami)"
    log_debug "  Runner OS: ${RUNNER_OS:-<not set>}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
fi

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
else
    log_debug "Using provided certificate name: $CERT_NAME"
fi

# Create temporary directory for certificate processing
TEMP_DIR=$(mktemp -d)
TEMP_CERT="$TEMP_DIR/$CERT_NAME"
log_debug "Created temporary directory: $TEMP_DIR"
log_debug "Temporary certificate path: $TEMP_CERT"

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
    log_debug "Certificate body length: ${#INPUT_CERTIFICATE_BODY} characters"
    echo "$INPUT_CERTIFICATE_BODY" > "$TEMP_CERT"

elif [[ "$INPUT_CERTIFICATE_SOURCE" =~ ^https?:// ]]; then
    # Certificate provided as URL
    log_info "Downloading certificate from URL: $INPUT_CERTIFICATE_SOURCE"
    log_debug "Using curl to download certificate..."
    
    if ! curl -fsSL -o "$TEMP_CERT" "$INPUT_CERTIFICATE_SOURCE"; then
        log_error "Failed to download certificate from URL"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    log_info "Certificate downloaded successfully"
    log_debug "Downloaded file size: $(stat -c%s "$TEMP_CERT" 2>/dev/null || stat -f%z "$TEMP_CERT" 2>/dev/null) bytes"

else
    # Certificate provided as file path
    if [ ! -f "$INPUT_CERTIFICATE_SOURCE" ]; then
        log_error "Certificate file not found: $INPUT_CERTIFICATE_SOURCE"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    log_info "Using certificate file: $INPUT_CERTIFICATE_SOURCE"
    log_debug "Source file size: $(stat -c%s "$INPUT_CERTIFICATE_SOURCE" 2>/dev/null || stat -f%z "$INPUT_CERTIFICATE_SOURCE" 2>/dev/null) bytes"
    cp "$INPUT_CERTIFICATE_SOURCE" "$TEMP_CERT"
fi

# Show certificate preview in debug mode
if [ "$INPUT_DEBUG" = "true" ]; then
    log_debug "Certificate content preview (first 3 lines):"
    head -n 3 "$TEMP_CERT" | sed 's/^/  /'
    log_debug "Certificate content preview (last 2 lines):"
    tail -n 2 "$TEMP_CERT" | sed 's/^/  /'
fi

# Validate certificate format (basic check for PEM format)
log_debug "Validating certificate format..."
if ! grep -q "BEGIN CERTIFICATE" "$TEMP_CERT"; then
    log_error "Invalid certificate format - does not appear to be a valid PEM certificate"
    rm -rf "$TEMP_DIR"
    exit 1
fi

log_info "Certificate format validated"

# Show certificate details in debug mode
if [ "$INPUT_DEBUG" = "true" ]; then
    log_debug "Certificate details:"
    if openssl x509 -in "$TEMP_CERT" -noout -subject -issuer -dates 2>/dev/null; then
        log_debug "Certificate parsed successfully"
    else
        log_debug "Could not parse certificate details with openssl (might be a bundle)"
    fi
    
    # Count number of certificates in file
    CERT_COUNT=$(grep -c "BEGIN CERTIFICATE" "$TEMP_CERT")
    log_debug "Number of certificates in file: $CERT_COUNT"
fi

# Install to system CA store
log_info "Installing certificate to system CA store"

# Create directory if it doesn't exist
if [ ! -d /usr/local/share/ca-certificates ]; then
    log_info "Creating /usr/local/share/ca-certificates directory"
    log_debug "Directory does not exist, creating with sudo..."
    sudo mkdir -p /usr/local/share/ca-certificates
else
    log_debug "Directory /usr/local/share/ca-certificates already exists"
fi

# Copy certificate
SYSTEM_CERT_PATH="/usr/local/share/ca-certificates/$CERT_NAME"
log_debug "Copying certificate to: $SYSTEM_CERT_PATH"
sudo cp "$TEMP_CERT" "$SYSTEM_CERT_PATH"
log_info "Certificate copied to: $SYSTEM_CERT_PATH"

# Verify copy
if [ "$INPUT_DEBUG" = "true" ]; then
    if [ -f "$SYSTEM_CERT_PATH" ]; then
        log_debug "Certificate file exists at destination"
        log_debug "Destination file size: $(stat -c%s "$SYSTEM_CERT_PATH" 2>/dev/null || stat -f%z "$SYSTEM_CERT_PATH" 2>/dev/null) bytes"
    else
        log_warn "Certificate file not found at destination (might be a permission issue)"
    fi
fi

# Update CA certificates
log_info "Updating system CA certificates"
log_debug "Running update-ca-certificates..."
if [ "$INPUT_DEBUG" = "true" ]; then
    sudo update-ca-certificates -v
else
    sudo update-ca-certificates
fi

log_info "System CA certificates updated successfully"

# Set outputs
log_debug "Setting GitHub Action outputs..."
echo "certificate-path=$SYSTEM_CERT_PATH" >> $GITHUB_OUTPUT
echo "certificate-name=$CERT_NAME" >> $GITHUB_OUTPUT
log_debug "Outputs set: certificate-path=$SYSTEM_CERT_PATH, certificate-name=$CERT_NAME"

# Cleanup
log_debug "Cleaning up temporary directory: $TEMP_DIR"
rm -rf "$TEMP_DIR"

if [ "$INPUT_DEBUG" = "true" ]; then
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Certificate installation completed successfully${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_debug "Final certificate location: $SYSTEM_CERT_PATH"
    log_debug "Certificate is now trusted by Docker and system tools"
    echo ""
else
    log_info "✓ Certificate installation completed successfully"
fi

