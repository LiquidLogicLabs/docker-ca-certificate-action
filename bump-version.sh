#!/bin/bash
# bump-version.sh - Simple version bumping and release script
# Usage: ./bump-version.sh [patch|minor|major]

set -e

BUMP_TYPE=${1:-patch}

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo "Usage: ./bump-version.sh [patch|minor|major]"
    echo ""
    echo "Examples:"
    echo "  ./bump-version.sh patch   # 1.0.0 → 1.0.1 (bug fixes)"
    echo "  ./bump-version.sh minor   # 1.0.0 → 1.1.0 (new features)"
    echo "  ./bump-version.sh major   # 1.0.0 → 2.0.0 (breaking changes)"
    exit 1
fi

echo "🔍 Determining current version..."

# Get current version from latest tag
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CURRENT_VERSION=${CURRENT_VERSION#v}  # Remove 'v' prefix

echo "   Current version: v$CURRENT_VERSION"

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Bump version based on type
case $BUMP_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
NEW_TAG="v$NEW_VERSION"

echo "   New version:     $NEW_TAG"
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  You have uncommitted changes."
    echo ""
    git status --short
    echo ""
    read -p "Commit these changes before release? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add -A
        read -p "Commit message: " COMMIT_MSG
        git commit -m "${COMMIT_MSG:-Prepare release $NEW_TAG}"
    else
        echo "❌ Please commit or stash changes before releasing"
        exit 1
    fi
fi

# Update CHANGELOG.md
if [ -f CHANGELOG.md ]; then
    echo "📝 Updating CHANGELOG.md..."
    
    TODAY=$(date +%Y-%m-%d)
    
    # Check if version already exists in changelog
    if grep -q "## \[$NEW_VERSION\]" CHANGELOG.md; then
        echo "   Version $NEW_VERSION already in CHANGELOG"
    else
        # Replace [Unreleased] with new version
        if grep -q "## \[Unreleased\]" CHANGELOG.md; then
            sed -i.bak "s/## \[Unreleased\]/## [Unreleased]\n\n## [$NEW_VERSION] - $TODAY/" CHANGELOG.md
            rm CHANGELOG.md.bak
            echo "   Added [$NEW_VERSION] section"
        else
            echo "   ⚠️  No [Unreleased] section found, skipping CHANGELOG update"
        fi
    fi
fi

# Show what will happen
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Ready to release $NEW_TAG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will:"
echo "  1. Commit CHANGELOG updates (if any)"
echo "  2. Create tag $NEW_TAG"
echo "  3. Push tag to origin"
echo "  4. GitHub Actions will:"
echo "     • Create GitHub release"
echo "     • Update major version tag (v$MAJOR)"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

# Commit CHANGELOG if modified
if ! git diff --quiet CHANGELOG.md 2>/dev/null; then
    echo "📝 Committing CHANGELOG updates..."
    git add CHANGELOG.md
    git commit -m "Update CHANGELOG for $NEW_TAG"
fi

# Create and push tag
echo "📌 Creating tag $NEW_TAG..."
git tag -a $NEW_TAG -m "Release $NEW_TAG"

echo "📤 Pushing to origin..."
git push origin main
git push origin $NEW_TAG

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Release initiated!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔗 Track progress at:"
echo "   https://github.com/ravensorb/actions/actions"
echo ""
echo "📦 Release will be available at:"
echo "   https://github.com/ravensorb/actions/releases/tag/$NEW_TAG"
echo ""
echo "✅ Users can now use:"
echo "   uses: ravensorb/actions/docker-certificate@$NEW_TAG"
echo "   uses: ravensorb/actions/docker-certificate@v$MAJOR"
echo ""

