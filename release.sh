#!/bin/bash
# release.sh - Create an official release (not a pre-release)
# Usage: ./release.sh [build_number]
#
# This script creates an official release with version: major.minor.build
# The build number defaults to the current GitHub run number or can be specified manually

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Official Release Creator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if we're on the main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    log_error "Releases must be created from the main branch"
    log_error "Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    log_error "You have uncommitted changes"
    echo ""
    git status --short
    echo ""
    log_error "Please commit or stash changes before releasing"
    exit 1
fi

# Pull latest changes
log_info "Pulling latest changes from origin..."
git fetch --all --tags
git pull origin main

# Get major.minor from latest official release tag
LATEST_TAG=$(git tag --sort=-version:refname | grep -v '-' | head -n 1)

if [ -z "$LATEST_TAG" ]; then
    # No previous release, start at 1.0
    MAJOR_MINOR="1.0"
    log_info "No previous release found, starting at: ${MAJOR_MINOR}"
else
    # Extract major.minor from latest tag (e.g., v1.2.45 -> 1.2)
    LATEST_TAG_CLEAN=${LATEST_TAG#v}  # Remove 'v' prefix
    MAJOR_MINOR=$(echo "$LATEST_TAG_CLEAN" | cut -d'.' -f1-2)
    log_info "Latest release: ${LATEST_TAG}"
    log_info "Using base version: ${MAJOR_MINOR}"
fi

# Determine build number
if [ -n "$1" ]; then
    BUILD_NUMBER="$1"
    log_info "Using provided build number: ${BUILD_NUMBER}"
else
    # Get the latest pre-release tag to extract build number
    LATEST_PRE=$(git tag --sort=-version:refname | grep "${MAJOR_MINOR}\." | grep '-' | head -n 1)
    
    if [ -n "$LATEST_PRE" ]; then
        # Extract build number from pre-release (e.g., v1.0.45-abc123 -> 45)
        BUILD_NUMBER=$(echo "$LATEST_PRE" | sed 's/^v//' | sed "s/${MAJOR_MINOR}\.//" | cut -d'-' -f1)
        log_info "Using build number from latest pre-release: ${BUILD_NUMBER}"
    else
        log_error "No pre-release found to extract build number"
        log_error "Please specify build number: ./release.sh <build_number>"
        exit 1
    fi
fi

# Build release version: major.minor.build
RELEASE_VERSION="${MAJOR_MINOR}.${BUILD_NUMBER}"
RELEASE_TAG="v${RELEASE_VERSION}"

log_info "Release version: ${RELEASE_TAG}"

# Check if this tag already exists
if git rev-parse "$RELEASE_TAG" >/dev/null 2>&1; then
    log_error "Tag ${RELEASE_TAG} already exists"
    log_error "Use a different build number or delete the existing tag"
    exit 1
fi

# Get the last official release (not pre-release)
LAST_RELEASE=$(git tag --sort=-version:refname | grep -v '-' | head -n 1)

if [ -z "$LAST_RELEASE" ]; then
    log_info "This will be the first official release"
    COMMITS=$(git log --pretty=format:"- %s (%h)" --no-merges)
else
    log_info "Last official release: ${LAST_RELEASE}"
    COMMITS=$(git log ${LAST_RELEASE}..HEAD --pretty=format:"- %s (%h)" --no-merges)
fi

# Generate changelog
log_info "Generating changelog..."

cat > release-notes.md << NOTES_EOF
## Release ${RELEASE_VERSION}

**Version:** \`${RELEASE_TAG}\`  
**Date:** $(date +%Y-%m-%d)  
**Build:** ${BUILD_NUMBER}

### Changes Since Last Release

NOTES_EOF

if [ -z "$COMMITS" ]; then
    echo "No new commits" >> release-notes.md
else
    echo "$COMMITS" >> release-notes.md
fi

cat >> release-notes.md << NOTES_EOF

---

### Installation

\`\`\`yaml
- uses: LiquidLogicLabs/docker-ca-certificate@${RELEASE_TAG}
  with:
    certificate-source: 'path/to/cert.crt'
\`\`\`

Or use the major version tag for automatic updates:

\`\`\`yaml
- uses: LiquidLogicLabs/docker-ca-certificate@v${MAJOR_MINOR%%.*}
  with:
    certificate-source: 'path/to/cert.crt'
\`\`\`

### Features

- 📁 Multiple input methods: Local file, URL, or inline certificate content
- 🔒 System integration: Installs to system CA store
- ✅ Simple and reliable
- 🛡️ Comprehensive error handling and validation
- 🔄 Idempotent: Safe to run multiple times
- 🐛 Enhanced debug logging

### Inputs

| Input | Description | Required |
|-------|-------------|----------|
| \`certificate-source\` | Certificate source: file path, URL, or 'inline' | Yes |
| \`certificate-body\` | Certificate content (required when source is 'inline') | No |
| \`certificate-name\` | Name for certificate file | No |
| \`debug\` | Enable debug output | No |

### Requirements

- Ubuntu runner (tested on ubuntu-22.04)
- Appropriate permissions to write to system directories

For more information, see the [README](https://github.com/LiquidLogicLabs/docker-ca-certificate).
NOTES_EOF

# Update CHANGELOG.md if it exists
if [ -f CHANGELOG.md ]; then
    log_info "Updating CHANGELOG.md..."
    
    TODAY=$(date +%Y-%m-%d)
    
    if grep -q "## \[$RELEASE_VERSION\]" CHANGELOG.md; then
        log_warn "Version $RELEASE_VERSION already in CHANGELOG"
    else
        # Add new version section
        if grep -q "## \[Unreleased\]" CHANGELOG.md; then
            sed -i.bak "s/## \[Unreleased\]/## [Unreleased]\n\n## [$RELEASE_VERSION] - $TODAY/" CHANGELOG.md
            rm CHANGELOG.md.bak
            log_info "Added [$RELEASE_VERSION] section to CHANGELOG"
        else
            log_warn "No [Unreleased] section found in CHANGELOG, skipping update"
        fi
    fi
fi

# Show summary and confirm
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 Release Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Version:      ${RELEASE_TAG}"
echo "  Build Number: ${BUILD_NUMBER}"
echo "  Branch:       ${CURRENT_BRANCH}"
echo "  Commit:       $(git rev-parse --short HEAD)"
echo ""
echo "This will:"
echo "  1. Commit CHANGELOG updates (if any)"
echo "  2. Create tag ${RELEASE_TAG}"
echo "  3. Push tag to origin"
echo "  4. Create GitHub release"
echo "  5. Update major version tag (v${MAJOR_MINOR%%.*})"
echo ""
echo -e "${YELLOW}Release Notes Preview:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -n 20 release-notes.md
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Continue with release? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warn "Release cancelled"
    rm -f release-notes.md
    exit 0
fi

# Commit CHANGELOG if modified
if [ -f CHANGELOG.md ] && ! git diff --quiet CHANGELOG.md; then
    log_info "Committing CHANGELOG updates..."
    git add CHANGELOG.md
    git commit -m "Update CHANGELOG for ${RELEASE_TAG}"
    git push origin main
fi

# Create and push tag
log_info "Creating tag ${RELEASE_TAG}..."
git tag -a ${RELEASE_TAG} -m "Release ${RELEASE_TAG}"

log_info "Pushing tag to origin..."
git push origin ${RELEASE_TAG}

# Create GitHub release using gh CLI if available
if command -v gh &> /dev/null; then
    log_info "Creating GitHub release..."
    gh release create ${RELEASE_TAG} \
        --title "Release ${RELEASE_TAG}" \
        --notes-file release-notes.md
    
    # Update major version tag
    MAJOR_TAG="v${MAJOR_MINOR%%.*}"
    log_info "Updating major version tag ${MAJOR_TAG}..."
    
    git tag -d ${MAJOR_TAG} 2>/dev/null || true
    git push origin :refs/tags/${MAJOR_TAG} 2>/dev/null || true
    git tag -a ${MAJOR_TAG} -m "Latest ${MAJOR_TAG}.x release"
    git push origin ${MAJOR_TAG}
    
    log_info "Major version tag ${MAJOR_TAG} updated to point to ${RELEASE_TAG}"
else
    log_warn "GitHub CLI (gh) not found - creating release manually"
    log_info "Please create the release manually at:"
    log_info "  https://github.com/LiquidLogicLabs/docker-ca-certificate/releases/new?tag=${RELEASE_TAG}"
    log_info "Use the content from: release-notes.md"
fi

# Cleanup
rm -f release-notes.md

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Release ${RELEASE_TAG} created successfully!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🔗 View release:"
echo "   https://github.com/LiquidLogicLabs/docker-ca-certificate/releases/tag/${RELEASE_TAG}"
echo ""
echo "📦 Users can now use:"
echo "   uses: LiquidLogicLabs/docker-ca-certificate@${RELEASE_TAG}"
echo "   uses: LiquidLogicLabs/docker-ca-certificate@v${MAJOR_MINOR%%.*}  (major version - auto-updates)"
echo ""

