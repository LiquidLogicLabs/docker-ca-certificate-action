# GitHub Actions Workflows

This directory contains the CI/CD workflows for the Docker CA Certificate Action.

## Workflows

### `ci.yml` - Testing & Pre-Releases

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`

**What it does:**
1. **Test Suite** - Runs comprehensive tests:
   - Local file installation
   - URL download
   - Inline certificate content
   - BuildKit.toml generation
   - Debug mode validation

2. **Pre-Release Creation** (only on push to main/develop, not on PRs):
   - Generates version: `v{major}.{minor}.{build}-{sha}`
   - Creates changelog from commits since last release
   - Creates GitHub pre-release
   - Cleans up old pre-releases (keeps last 10)

**Example output:** `v1.0.45-a3f2b1c`

### `release.yml` - Official Releases

**Triggers:**
- Push of version tags (v*.*.*)
- Manual workflow dispatch

**What it does:**
1. **Quick Validation**: Runs essential tests before release
2. **Automatic Release Creation**:
   - Extracts version from git tag
   - Generates release notes from changelog
   - Creates GitHub release
   - Updates major version tags (v1, v2, etc.)

**Safety Features:**
- ✅ **Pre-release validation**: Runs quick tests before creating release
- ✅ **BuildKit testing**: Validates the new BuildKit feature
- ✅ **Certificate validation**: Ensures basic functionality works

**Example:** When you push tag `v1.0.2`, it validates the action works, then creates the GitHub release.

## Release Process

### **Ultra-Simple Releases**

The release process is now **extremely simple**:

```bash
# Create a patch release (bug fixes)
npx standard-version --release-as patch

# Create a minor release (new features)  
npx standard-version --release-as minor

# Create a major release (breaking changes)
npx standard-version --release-as major
```

**That's it!** The command will:
- ✅ Bump version in package.json
- ✅ Generate changelog from conventional commits
- ✅ Create git tag
- ✅ Push to GitHub
- ✅ Trigger `release.yml` to create GitHub release

### **Conventional Commits**

Use conventional commit format for automatic changelog generation:

```bash
# Bug fixes
git commit -m "fix: resolve certificate validation issue"

# New features  
git commit -m "feat: add buildkit.toml generation support"

# Breaking changes
git commit -m "feat!: change input parameter names"

# Documentation
git commit -m "docs: update installation guide"
```

## Versioning

### Version Source
Versions are derived from **git tags** using semantic versioning.

### Version Formats

| Type | Format | Example | Created By |
|------|--------|---------|------------|
| Pre-Release | `v{major}.{minor}.{build}-{sha}` | `v1.0.45-a3f2b1c` | Automatic on push |
| Official Release | `v{major}.{minor}.{patch}` | `v1.0.2` | `npx standard-version` |
| Major Version Tag | `v{major}` | `v1` | Automatic (points to latest) |

## Workflow Dependencies

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW DEPENDENCIES                   │
└─────────────────────────────────────────────────────────────┘

Development Flow:
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Commit    │───▶│     ci.yml   │───▶│   Release   │
│   & Push    │    │ (Automatic)  │    │ (Manual)    │
└─────────────┘    └──────────────┘    └─────────────┘
                           │                    │
                           ▼                    ▼
                    ┌──────────────┐    ┌─────────────┐
                    │ v1.0.45-abc  │    │  v1.0.45   │
                    │ (Pre-release)│    │ (Official)  │
                    │ + Full Tests │    │ + Validation│
                    └──────────────┘    └─────────────┘

Release Safety:
┌─────────────────────────────────────────────────────────────┐
│  Release workflow includes quick validation tests          │
│  to ensure action works before creating GitHub release     │
└─────────────────────────────────────────────────────────────┘
```

## Tools Used

- **standard-version**: Industry-standard release automation
- **conventional-changelog**: Automatic changelog generation  
- **GitHub Actions**: Automated testing and release creation
- **act**: Local testing of GitHub Actions

## Quick Reference

### **Testing Locally**
```bash
./act-build.sh  # Run all tests locally
```

### **Creating Releases**
```bash
npx standard-version --release-as patch   # Bug fix
npx standard-version --release-as minor   # New feature
npx standard-version --release-as major   # Breaking change
```

### **Viewing Releases**
- **Pre-releases**: GitHub Actions tab → ci-pre-release
- **Official releases**: GitHub Releases page
- **Local testing**: `act-build.sh` script