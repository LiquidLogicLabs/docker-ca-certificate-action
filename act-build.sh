#!/bin/bash
# act-build.sh - Run tests locally using act (nektos/act)

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing CA Certificate Import Action with act"
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

# Run the test job from ci-pre-release workflow
echo "▶ Running test suite from ci-pre-release.yml..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if act -W .github/workflows/ci-pre-release.yml -j test; then
    echo ""
    echo "✅ All tests passed"
else
    echo ""
    echo "❌ Tests failed"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All tests completed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Review test output above"
echo "  2. Fix any issues"
echo "  3. Push to GitHub when ready"
echo "  4. Automatic pre-release will be created"
echo ""
echo "To create an official release:"
echo "  ./release.sh [build_number]"
echo ""
echo "To bump version:"
echo "  ./bump-version.sh minor  # 1.0 → 1.1"
echo "  ./bump-version.sh major  # 1.x → 2.0"
echo ""

