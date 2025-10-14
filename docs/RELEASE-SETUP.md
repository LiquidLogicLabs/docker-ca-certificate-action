# Release Automation - Complete Setup

## ✅ What's Been Set Up

Your release automation is **ready to use**. Here's what's included:

### 1. One-Command Local Release ⭐ **RECOMMENDED**

**File:** `bump-version.sh`

**Usage:**
```bash
./bump-version.sh patch   # 1.0.0 → 1.0.1 (bug fixes)
./bump-version.sh minor   # 1.0.0 → 1.1.0 (new features)  
./bump-version.sh major   # 1.0.0 → 2.0.0 (breaking changes)
```

**What it does:**
- ✅ Auto-calculates next version from git tags
- ✅ Updates CHANGELOG.md with release date
- ✅ Commits changelog changes
- ✅ Creates version tag (e.g., v1.0.1)
- ✅ Pushes tag to GitHub
- ✅ Triggers automated GitHub Actions release workflow

### 2. Automated GitHub Workflow

**File:** `.github/workflows/release.yml`

**Triggers:** Automatically when you push a version tag (v*.*.*)

**What it does:**
- ✅ Extracts changelog for the version
- ✅ Creates GitHub Release with notes
- ✅ Updates major version tag (v1, v2, etc.)
- ✅ Makes action available at both `@v1.0.1` and `@v1`

### 3. Manual GitHub UI Release

**File:** `.github/workflows/manual-release.yml`

**Access:** GitHub Actions tab → Manual Release → Run workflow

**Use case:** Release from GitHub UI without local setup

### 4. Validation Workflow

**File:** `.github/workflows/version-tag.yml`

**Purpose:** Validates CHANGELOG.md in pull requests

## 🚀 Quick Start

### First Release (v1.0.0)

```bash
# 1. Make sure CHANGELOG.md is up to date
# 2. Run the bump script
./bump-version.sh major

# That's it! 
# - Tag is created and pushed
# - GitHub Actions creates the release
# - Major version tag (v1) is updated
```

### Subsequent Releases

```bash
# Bug fix release
./bump-version.sh patch

# New feature release  
./bump-version.sh minor

# Breaking change release
./bump-version.sh major
```

## 📋 Release Workflow Diagram

```
┌─────────────────────────────────────────────┐
│  Developer: ./bump-version.sh patch         │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│  Script:                                    │
│  1. Calculate new version (v1.0.1)          │
│  2. Update CHANGELOG.md                     │
│  3. Commit changes                          │
│  4. Create tag v1.0.1                       │
│  5. Push to GitHub                          │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│  GitHub Actions (.github/workflows/):       │
│  1. Detect tag push (v1.0.1)                │
│  2. Extract changelog notes                 │
│  3. Create GitHub Release                   │
│  4. Update major tag (v1 → v1.0.1)          │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│  Result: Users can now use:                 │
│  - @v1.0.1 (specific version)               │
│  - @v1 (latest v1.x.x - auto-updates)       │
└─────────────────────────────────────────────┘
```

## 📝 Files Created

```
.github/workflows/
├── release.yml           # Automated release on tag push
├── manual-release.yml    # UI-triggered release
├── test.yml             # Existing tests
└── version-tag.yml      # CHANGELOG validation

Scripts:
├── bump-version.sh      # ⭐ Main release script
├── release-gh.sh        # GitHub CLI alternative
└── release.sh           # Basic version (no automation)

Documentation:
├── QUICK-RELEASE.md     # Quick reference guide
├── RELEASE-SETUP.md     # This file
├── RELEASE-OPTIONS.md   # Comparison of methods
└── RELEASING.md         # Detailed guide
```

## 🎯 Recommended Usage

**Day-to-day development:**
1. Work on features/fixes
2. Update CHANGELOG.md under `[Unreleased]`
3. When ready to release: `./bump-version.sh patch|minor|major`
4. Done! Check GitHub Actions for release status

## 🔧 Customization

### Change Changelog Format

Edit `bump-version.sh` line that updates CHANGELOG.md:
```bash
sed -i "s/## \[Unreleased\]/## [Unreleased]\n\n## [$NEW_VERSION] - $TODAY/"
```

### Change Release Notes

Edit `.github/workflows/release.yml` changelog extraction section:
```yaml
- name: Extract changelog for this version
  run: |
    # Customize this section
```

### Pre-release / Beta Versions

```bash
# Create tag manually for beta
git tag -a v1.1.0-beta.1 -m "Beta release"
git push origin v1.1.0-beta.1

# GitHub Actions will create pre-release
```

## 🐛 Troubleshooting

### Script shows "Permission denied"
```bash
chmod +x bump-version.sh
```

### "No tag found" on first release
Normal! The script defaults to v0.0.0 if no tags exist.

### GitHub Actions not running
- Check: https://github.com/ravensorb/actions/actions
- Verify you pushed the tag: `git push origin v1.0.1`
- Check workflow permissions in repo settings

### Want to delete/redo a release
```bash
# Delete tag locally
git tag -d v1.0.1

# Delete tag remotely  
git push origin :refs/tags/v1.0.1

# Delete release from GitHub UI
# Then re-run bump-version.sh
```

## 📚 Additional Documentation

- **Quick Reference:** [QUICK-RELEASE.md](QUICK-RELEASE.md)
- **Method Comparison:** [RELEASE-OPTIONS.md](RELEASE-OPTIONS.md)  
- **Detailed Guide:** [RELEASING.md](RELEASING.md)

## ✨ Summary

**To release this action, just run:**
```bash
./bump-version.sh patch
```

**Everything else is automated!** 🎉

