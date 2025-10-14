#!/bin/bash
# test-local.sh - Quick local test with act

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing Docker Certificate Action with act"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "❌ act is not installed"
    echo ""
    echo "Install options:"
    echo "  macOS:  brew install act"
    echo "  Linux:  curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
    echo "  Docs:   https://github.com/nektos/act"
    exit 1
fi

echo "✓ act is installed ($(act --version))"
echo ""

# Create test certificate if not exists
if [ ! -f test-certs/test-ca.crt ]; then
    echo "📝 Creating test certificate..."
    mkdir -p test-certs
    openssl req -x509 -newkey rsa:2048 -keyout test-certs/test-key.pem \
      -out test-certs/test-ca.crt -days 365 -nodes \
      -subj "/C=US/ST=Test/L=Test/O=Test/CN=test.local" 2>/dev/null
    echo "✓ Test certificate created"
else
    echo "✓ Test certificate exists"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Running tests..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Determine which tests to run
TEST_SUITE=${1:-all}

run_test() {
    local test_name=$1
    local job_name=$2
    
    echo ""
    echo "▶ Test: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if act -W .github/workflows/test.yml -j "$job_name"; then
        echo "✅ $test_name passed"
    else
        echo "❌ $test_name failed"
        return 1
    fi
}

case $TEST_SUITE in
    local|file)
        run_test "Local file installation" "test-local-file"
        ;;
    url)
        run_test "URL download" "test-url"
        ;;
    inline)
        run_test "Inline content" "test-inline"
        ;;
    all)
        run_test "Local file installation" "test-local-file"
        run_test "URL download" "test-url"
        run_test "Inline content" "test-inline"
        ;;
    *)
        echo "Usage: $0 [all|local|url|inline]"
        exit 1
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All tests completed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Review test output above"
echo "  2. Fix any issues"
echo "  3. Push to GitHub when ready"
echo "  4. Release with: ./bump-version.sh major"
echo ""

