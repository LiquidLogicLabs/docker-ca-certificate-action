# Ultra-Simple Release Automation 🚀

The **simplest possible** release automation using `npx` and existing tools.

## ⚡ **One-Line Releases**

### **Method 1: One-Line Release Commands (Recommended)**

```bash
# Full Releases (creates tag, triggers CI/CD pipeline)
npm run release:patch      # v1.0.1 → v1.0.2 (bug fixes)
npm run release:minor      # v1.0.1 → v1.1.0 (new features)
npm run release:major      # v1.0.1 → v2.0.0 (breaking changes)

# Pre-Releases (creates pre-release tag, triggers CI/CD pipeline)
npm run release:pre-alpha  # v1.0.1 → v1.0.2-alpha.0
npm run release:pre-beta   # v1.0.1 → v1.0.2-beta.0
npm run release:pre-rc     # v1.0.1 → v1.0.2-rc.0
npm run release:pre-dev    # v1.0.1 → v1.0.2-dev.0

# Interactive mode (asks what type)
npm run release
```

**That's it!** Commands create git tags which automatically trigger the CI/CD pipeline for testing, building, packaging, and releasing.

### **Method 2: Direct standard-version**

```bash
# Direct standard-version commands
npx standard-version --release-as patch   # 1.0.1 → 1.0.2
npx standard-version --release-as minor   # 1.0.1 → 1.1.0  
npx standard-version --release-as major   # 1.0.1 → 2.0.0
npx standard-version                       # Interactive mode
```

### **Method 3: Local Testing**

```bash
# Test locally with act
npm run test:local        # Run tests locally
npm run ci:local          # Run full CI/CD pipeline locally
```

## 🏗️ **CI/CD Pipeline Architecture**

The release system uses a unified CI/CD pipeline that works on:

- ✅ **GitHub Actions** - Full automation on GitHub
- ✅ **Gitea Actions** - Compatible with Gitea CI/CD
- ✅ **Local Development** - Test with `act` locally

### **Pipeline Flow:**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Push/Tag      │───▶│   CI/CD Pipeline │───▶│   Auto Release  │
│   (Auto)        │    │   (Test/Build)   │    │   (Tag-based)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
┌─────────────────┐    ┌──────────────────┐
│   npx command   │───▶│   Manual Release │
│   (Manual)      │    │   (Validation)   │
└─────────────────┘    └──────────────────┘
```

### **Pipeline Jobs:**

1. **Detect Changes** - Determines if CI/CD should run (skips docs-only changes)
2. **Test** - Runs comprehensive tests (certificate installation, BuildKit generation)
3. **Build** - Validates and packages the action
4. **Release** - Creates GitHub release (only on tag pushes)


## 🎯 **What Happens Automatically**

When you run any of the above commands:

1. ✅ **Version Detection**: Reads current version from git tags
2. ✅ **Version Bump**: Calculates next version (patch/minor/major)
3. ✅ **Changelog**: Generates changelog from conventional commits
4. ✅ **Package Update**: Updates package.json version
5. ✅ **Git Commit**: Commits changes with proper message
6. ✅ **Git Tag**: Creates version tag (e.g., v1.0.2)
7. ✅ **Push**: Pushes commits and tags to GitHub
8. ✅ **GitHub Release**: GitHub Actions creates the release automatically

## 📋 **Commit Message Format**

Use conventional commits for automatic changelog generation:

```bash
# Bug fixes (creates patch release)
git commit -m "fix: resolve certificate validation issue"

# New features (creates minor release)
git commit -m "feat: add buildkit.toml generation support"

# Breaking changes (creates major release)  
git commit -m "feat!: change input parameter names"

# Documentation
git commit -m "docs: update installation guide"

# Chores (hidden in changelog)
git commit -m "chore: update dependencies"
```

## 🏗️ **System Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                ULTRA-SIMPLE RELEASE FLOW                   │
└─────────────────────────────────────────────────────────────┘

Developer Flow:
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Commit    │───▶│ npx release  │───▶│   GitHub    │
│ Conventional│    │ command      │    │   Release   │
└─────────────┘    └──────────────┘    └─────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ Auto-changelog│
                    │ Auto-version  │
                    │ Auto-tag      │
                    └──────────────┘
```

## 🛠️ **Tools Used**

- **[standard-version](https://github.com/conventional-changelog/standard-version)**: Industry-standard release automation
- **[conventional-changelog](https://github.com/conventional-changelog/conventional-changelog)**: Automatic changelog generation
- **[npx](https://www.npmjs.com/package/npx)**: Run packages without installation
- **GitHub Actions**: Automated release creation

## 📚 **Usage Examples**

### **Creating a Pre-Release**

```bash
# 1. Add feature and commit
git commit -m "feat: add new certificate validation"

# 2. Create alpha pre-release
npm run release:pre-alpha

# Result: v1.0.1 → v1.0.2-alpha.0
# ✅ Pre-release created for testing
# ✅ GitHub release created automatically
# ✅ Safe to iterate and test

# 3. If more changes needed, increment pre-release
npm run release:pre-alpha  # v1.0.2-alpha.0 → v1.0.2-alpha.1

# 4. When ready, promote to full release
npm run release:patch      # v1.0.2-alpha.1 → v1.0.2
```

### **Creating a Bug Fix Release**

```bash
# 1. Fix the bug and commit
git commit -m "fix: resolve certificate parsing error"

# 2. Create patch release
npm run release:patch

# Result: v1.0.1 → v1.0.2
# ✅ Changelog updated
# ✅ GitHub release created
# ✅ Major tag (v1) updated
```

### **Creating a Feature Release**

```bash
# 1. Add feature and commit
git commit -m "feat: add support for multiple certificate formats"

# 2. Create minor release
npm run release:minor

# Result: v1.0.2 → v1.1.0
# ✅ Changelog updated with new feature
# ✅ GitHub release created
# ✅ Major tag (v1) updated
```

### **Creating a Breaking Change Release**

```bash
# 1. Make breaking change and commit
git commit -m "feat!: rename certificate-source to cert-source"

# 2. Create major release
npm run release:major

# Result: v1.1.0 → v2.0.0
# ✅ Changelog updated with breaking changes
# ✅ GitHub release created
# ✅ Major tag (v2) created
```

## 🎨 **Generated Changelog Example**

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-01-15

### Features

- add buildkit.toml generation support (a1b2c3d)
- add support for multiple certificate formats (e4f5g6h)

### Bug Fixes

- resolve certificate parsing error (i7j8k9l)

## [1.0.2] - 2025-01-10

### Bug Fixes

- fix certificate validation issue (m1n2o3p)
```

## ⚙️ **Configuration**

### **Package.json Scripts**

```json
{
  "scripts": {
    "release": "standard-version",
    "release:patch": "standard-version --release-as patch",
    "release:minor": "standard-version --release-as minor", 
    "release:major": "standard-version --release-as major"
  }
}
```

### **GitHub Actions Integration**

The existing `.github/workflows/release.yml` automatically:
- ✅ Creates GitHub releases when tags are pushed
- ✅ Updates major version tags (v1, v2, etc.)
- ✅ Generates release notes from changelog

## 🚀 **Migration from Complex System**

### **Before (Complex)**
```bash
# Old buggy system
./release.sh  # Had version parsing bugs
# Manual GitHub release creation
# Inconsistent versioning
# Complex Node.js scripts
```

### **After (Ultra-Simple)**
```bash
# New simple system
npx standard-version --release-as patch  # Just works!
# Automatic GitHub releases
# Consistent semantic versioning
# Industry-standard tools
```

## 🎯 **Benefits**

- ✅ **Zero Setup**: No installation required
- ✅ **Industry Standard**: Uses proven tools
- ✅ **Automatic**: Changelog, versioning, releases
- ✅ **Reliable**: No custom bugs or edge cases
- ✅ **Flexible**: Works with any conventional commit format
- ✅ **Fast**: Single command does everything

## 🆘 **Troubleshooting**

### **"npx not found"**
```bash
# Install Node.js (includes npx)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### **"No commits found"**
```bash
# Make sure you have conventional commits
git log --oneline -5
# Should see: feat:, fix:, docs:, etc.
```

### **"GitHub release not created"**
```bash
# Check GitHub Actions workflow
# Should trigger automatically on tag push
```

## 🎉 **Summary**

**Ultra-simple release automation in one command:**

```bash
npx standard-version --release-as patch
```

**That's it!** 🚀

- No installation
- No setup  
- No bugs
- Just works
