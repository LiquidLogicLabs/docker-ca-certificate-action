#!/bin/bash
# bump-version.sh - Bump major or minor version
# Usage: ./bump-version.sh [minor|major]
#
# This creates an initial release with the new version number.
# Subsequent releases will continue from this base.

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

BUMP_TYPE=${1:-minor}

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(minor|major)$ ]]; then
    echo ""
    echo "Usage: ./bump-version.sh [minor|major]"
    echo ""
    echo "Examples:"
    echo "  ./bump-version.sh minor   # 1.0 → 1.1 (new features)"
    echo "  ./bump-version.sh major   # 1.x → 2.0 (breaking changes)"
    echo ""
    exit 1
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📈 Version Bump - ${BUMP_TYPE}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if we're on the main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    log_error "Version bumps must be done from the main branch"
    log_error "Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    log_error "You have uncommitted changes"
    echo ""
    git status --short
    echo ""
    log_error "Please commit or stash changes before bumping version"
    exit 1
fi

# Pull latest changes
log_info "Pulling latest changes from origin..."
git fetch --all --tags
git pull origin main

# Get current version from latest tag
LATEST_TAG=$(git tag --sort=-version:refname | grep -v '-' | head -n 1)

if [ -z "$LATEST_TAG" ]; then
    # No previous release, start at 1.0
    CURRENT_MAJOR=1
    CURRENT_MINOR=0
    log_info "No previous release found, starting at 1.0"
else
    # Extract major.minor from latest tag
    LATEST_TAG_CLEAN=${LATEST_TAG#v}  # Remove 'v' prefix
    CURRENT_MAJOR=$(echo "$LATEST_TAG_CLEAN" | cut -d'.' -f1)
    CURRENT_MINOR=$(echo "$LATEST_TAG_CLEAN" | cut -d'.' -f2)
    log_info "Current version: ${CURRENT_MAJOR}.${CURRENT_MINOR} (from ${LATEST_TAG})"
fi

# Calculate new version
case $BUMP_TYPE in
    major)
        NEW_MAJOR=$((CURRENT_MAJOR + 1))
        NEW_MINOR=0
        ;;
    minor)
        NEW_MAJOR=$CURRENT_MAJOR
        NEW_MINOR=$((CURRENT_MINOR + 1))
        ;;
esac

NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}.1"
NEW_TAG="v${NEW_VERSION}"

log_info "New version: ${NEW_TAG}"

# Check if this tag already exists
if git rev-parse "$NEW_TAG" >/dev/null 2>&1; then
    log_error "Tag ${NEW_TAG} already exists"
    exit 1
fi

# Show summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 Version Bump Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Current:  ${CURRENT_MAJOR}.${CURRENT_MINOR}"
echo "  New:      ${NEW_MAJOR}.${NEW_MINOR}"
echo "  Tag:      ${NEW_TAG}"
echo "  Branch:   ${CURRENT_BRANCH}"
echo "  Commit:   $(git rev-parse --short HEAD)"
echo ""
echo "This will:"
echo "  1. Create initial release tag ${NEW_TAG}"
echo "  2. Push tag to origin"
echo "  3. GitHub Actions will create the release"
echo "  4. Future releases will use ${NEW_MAJOR}.${NEW_MINOR}.x"
echo "  5. Update major version tag (v${NEW_MAJOR})"
echo ""
echo -e "${YELLOW}Note: This is a version bump, not a feature release.${NC}"
echo -e "${YELLOW}Make sure you've merged all changes for the new version first.${NC}"
echo ""

read -p "Continue with version bump? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warn "Version bump cancelled"
    exit 0
fi

# Create and push tag
log_info "Creating tag ${NEW_TAG}..."
git tag -a ${NEW_TAG} -m "Bump version to ${NEW_MAJOR}.${NEW_MINOR}"

log_info "Pushing tag to origin..."
git push origin ${NEW_TAG}

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Version bumped to ${NEW_MAJOR}.${NEW_MINOR}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎉 Version bump complete!"
echo ""
echo "Next steps:"
echo "  • GitHub Actions will create release ${NEW_TAG}"
echo "  • Future pre-releases: v${NEW_MAJOR}.${NEW_MINOR}.{build}-{sha}"
echo "  • Future releases: v${NEW_MAJOR}.${NEW_MINOR}.{build}"
echo ""
echo "📦 Track progress at:"
echo "   https://github.com/LiquidLogicLabs/docker-ca-certificate/actions"
echo ""
