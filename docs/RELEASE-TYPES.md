# Release Types: Pre-Release vs Official Release

## Overview

This project uses **two distinct release types** that are automatically recognized by GitHub and package managers.

## Release Types

### Pre-Release 🟡

**Format:** `v{major}.{minor}.{build}-{sha}`  
**Example:** `v1.0.45-a3f2b1c`  
**Created:** Automatically on every push to `main` or `develop`  
**Marked as:** Pre-release on GitHub  
**Purpose:** Testing, staging, development  

**Characteristics:**
- ✅ Contains commit SHA for traceability
- ✅ Marked as pre-release on GitHub (orange badge)
- ✅ Not recommended for production
- ✅ Auto-cleaned up (keeps last 10)
- ✅ Changelog includes all commits since last official release

### Official Release ✓

**Format:** `v{major}.{minor}.{build}`  
**Example:** `v1.0.45`  
**Created:** Manually with `./release.sh`  
**Marked as:** Official release on GitHub  
**Purpose:** Production use  

**Characteristics:**
- ✅ Clean version number (no SHA)
- ✅ Marked as official release on GitHub (green badge)
- ✅ Recommended for production
- ✅ Appears as "Latest" on GitHub
- ✅ Changelog includes all commits since last official release
- ✅ Updates major version tag (v1, v2, etc.)

## Visual Comparison

```
┌──────────────────────────────────────────────────────────────┐
│                     GitHub Releases Page                      │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  v1.0.45                    Latest ✓ Official Release        │
│  Release 1.0.45                                              │
│  Published on Oct 14, 2025                                   │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ ✓ Production Ready                                     │  │
│  │ • Bug fixes and improvements                           │  │
│  │ • Enhanced debug logging                               │  │
│  └────────────────────────────────────────────────────────┘  │
│  📦 Assets: Source code (zip) • Source code (tar.gz)        │
│                                                               │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                               │
│  v1.0.45-a3f2b1c            🟡 Pre-release                   │
│  Pre-Release 1.0.45-a3f2b1c                                  │
│  Published on Oct 13, 2025                                   │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ ⚠️  This is a pre-release build                        │  │
│  │ • Automatically generated for testing                  │  │
│  │ • Use for staging/development only                     │  │
│  └────────────────────────────────────────────────────────┘  │
│  📦 Assets: Source code (zip) • Source code (tar.gz)        │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## How GitHub Identifies Release Types

### Pre-Release Flag

GitHub uses the `prerelease` flag when creating releases:

```yaml
# ci-pre-release.yml (automatic)
- uses: softprops/action-gh-release@v1
  with:
    prerelease: true  ← Marks as pre-release

# manual-release.yml (manual)
- uses: softprops/action-gh-release@v1
  with:
    prerelease: false  ← Marks as official release
```

### Latest Release

GitHub automatically marks the **most recent official release** (not pre-release) as "Latest".

## Semantic Versioning Compliance

Both release types follow **SemVer 2.0.0**:

### Official Release
```
v1.0.45
 │ │ └── Build/Patch number
 │ └──── Minor version
 └────── Major version
```

### Pre-Release
```
v1.0.45-a3f2b1c
 │ │ │   └────── Pre-release identifier (commit SHA)
 │ │ └────────── Build/Patch number
 │ └──────────── Minor version
 └────────────── Major version
```

**Note:** The `-{identifier}` suffix is the standard SemVer way to denote pre-releases.

## Usage in GitHub Actions

### Using Pre-Release

```yaml
- uses: LiquidLogicLabs/docker-ca-certificate@v1.0.45-a3f2b1c
  with:
    certificate-source: 'test.crt'
```

**Use cases:**
- Testing new features
- Staging environments
- CI/CD pipelines (non-production)
- Beta testing

### Using Official Release

```yaml
# Pin to specific version
- uses: LiquidLogicLabs/docker-ca-certificate@v1.0.45
  with:
    certificate-source: 'production.crt'

# Or use major version tag (auto-updates)
- uses: LiquidLogicLabs/docker-ca-certificate@v1
  with:
    certificate-source: 'production.crt'
```

**Use cases:**
- Production deployments
- Stable releases
- Customer-facing systems

## Complete Workflow

### Development Cycle

```bash
# Day 1: Work on feature
git commit -m "feat: Add certificate validation"
git push origin main
# → Creates: v1.0.45-a3f2b1c (pre-release)

# Day 2: More changes
git commit -m "fix: Correct error handling"
git push origin main
# → Creates: v1.0.46-def456 (pre-release)

# Day 3: More improvements
git commit -m "docs: Update README"
git push origin main
# → Creates: v1.0.47-ghi789 (pre-release)
```

### Production Release

```bash
# Test the latest pre-release
# uses: LiquidLogicLabs/docker-ca-certificate@v1.0.47-ghi789

# If tests pass, promote to official release
./release.sh 47

# → Creates: v1.0.47 (official release)
# → Updates: v1 → v1.0.47
```

## Version Progression Example

```
Timeline View:

Oct 10  v1.0.42-abc123  🟡 Pre-release  (auto)
Oct 11  v1.0.43-def456  🟡 Pre-release  (auto)
Oct 12  v1.0.44-ghi789  🟡 Pre-release  (auto)
Oct 13  v1.0.44         ✓  Official     (manual: ./release.sh 44)
        ↑
        Latest Release

Oct 14  v1.0.45-jkl012  🟡 Pre-release  (auto)
Oct 15  v1.0.46-mno345  🟡 Pre-release  (auto)
Oct 16  v1.0.46         ✓  Official     (manual: ./release.sh 46)
        ↑
        Latest Release (updated)
```

## API Access

### GitHub API

```bash
# Get latest official release
curl -s https://api.github.com/repos/LiquidLogicLabs/docker-ca-certificate/releases/latest

# Get all releases (including pre-releases)
curl -s https://api.github.com/repos/LiquidLogicLabs/docker-ca-certificate/releases

# Filter by type
curl -s https://api.github.com/repos/LiquidLogicLabs/docker-ca-certificate/releases \
  | jq '.[] | select(.prerelease == false)'  # Official only
```

### Git Tags

```bash
# List all tags
git tag --sort=-version:refname

# Official releases only (no pre-release suffix)
git tag --sort=-version:refname | grep -v '-'

# Pre-releases only (has pre-release suffix)
git tag --sort=-version:refname | grep '-'
```

## Node.js/npm Compatibility

### Package Version Ranges

```json
{
  "dependencies": {
    "your-package": "1.0.45",          // Exact version
    "your-package": "^1.0.45",         // Compatible (1.0.x)
    "your-package": "~1.0.45",         // Patch updates only
    "your-package": ">=1.0.45",        // Minimum version
    "your-package": "1.0.45-alpha.1"   // Pre-release
  }
}
```

### Version Comparison

npm/Node.js automatically handles pre-release versions:

```javascript
const semver = require('semver');

semver.gt('1.0.45', '1.0.45-a3f2b1c');  // true
// Official releases are always > pre-releases with same base

semver.satisfies('1.0.45-a3f2b1c', '^1.0.0');  // true
// Pre-releases satisfy version ranges
```

## Best Practices

### For Developers

1. **Test pre-releases** before creating official releases
2. **Use descriptive commit messages** for better changelogs
3. **Monitor GitHub Actions** for pre-release creation
4. **Bump versions** when introducing breaking changes

### For Users

1. **Use official releases** for production
2. **Use pre-releases** for testing and staging
3. **Pin to specific versions** for stability
4. **Use major tags** (v1, v2) for auto-updates

### For CI/CD

1. **Pre-releases** for feature branches and testing
2. **Official releases** for production deployments
3. **Monitor release notes** for changes
4. **Automate testing** against pre-releases

## Troubleshooting

### "Why are all my releases marked as pre-release?"

Check that you're using `./release.sh` for official releases, not just pushing code. Every push creates a pre-release automatically.

### "How do I know which version to use?"

- **Production:** Use the "Latest" release (official)
- **Testing:** Use the most recent pre-release
- **Stability:** Pin to a specific version

### "Can I delete old pre-releases?"

Yes! The system automatically keeps only the last 10 pre-releases. Older ones are cleaned up automatically.

## Summary

| Aspect | Pre-Release | Official Release |
|--------|-------------|------------------|
| **Format** | `v1.0.45-a3f2b1c` | `v1.0.45` |
| **Created** | Automatically | Manually |
| **GitHub Badge** | 🟡 Pre-release | ✓ Official |
| **Latest Tag** | No | Yes |
| **Production** | ❌ Not recommended | ✅ Recommended |
| **Cleaned Up** | Yes (keeps 10) | No (permanent) |
| **Major Tag** | No | Yes (v1, v2) |

---

**Quick Command:**
```bash
# Check what type of release a tag is
git show v1.0.45:CHANGELOG.md  # If exists, official
                                # If pre-release, check GitHub
```

