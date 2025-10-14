# Release Workflow Guide

This document describes the automated release workflow for the Docker CA Certificate Action.

## Overview

The project uses a **dual-release strategy**:

1. **Automatic Pre-Releases** - Created on every push to `main` or `develop`
2. **Manual Official Releases** - Created when you're ready to promote a pre-release to production

## Version Scheme

### Pre-Release Versions
Format: `major.minor.build-shortsha`

Example: `v1.0.45-a3f2b1c`

- `major.minor` - Read from `VERSION` file in repo root
- `build` - GitHub Actions run number
- `shortsha` - First 7 characters of git commit SHA

### Official Release Versions
Format: `major.minor.build`

Example: `v1.0.45`

- `major.minor` - Read from `VERSION` file in repo root
- `build` - Same build number as the pre-release you're promoting

## Automatic Pre-Releases

### How It Works

Every push to `main` or `develop` triggers:

1. **Test Suite** runs all tests:
   - Local file installation test
   - URL download test
   - Inline content test
   
2. **If tests pass**, a pre-release is automatically created:
   - Version: `v1.0.<run_number>-<short_sha>`
   - Tagged as pre-release in GitHub
   - Changelog generated from commits since last official release
   - Old pre-releases cleaned up (keeps last 10)

### Workflow File

`.github/workflows/ci-pre-release.yml`

### What You See

- ✅ Tests pass/fail in GitHub Actions
- 📦 New pre-release appears in Releases section
- 🏷️ Tag created automatically: `v1.0.45-a3f2b1c`
- 📝 Changelog with all commits since last release

### Using Pre-Releases

```yaml
# Use specific pre-release for testing
- uses: LiquidLogicLabs/docker-ca-certificate@v1.0.45-a3f2b1c
  with:
    certificate-source: 'path/to/cert.crt'
```

## Official Releases

### Method 1: Local Script (Recommended)

Use the `release.sh` script for full control:

```bash
# Create release from latest pre-release
./release.sh

# Or specify a specific build number
./release.sh 45
```

#### What the Script Does

1. ✅ Verifies you're on `main` branch
2. ✅ Checks for uncommitted changes
3. ✅ Pulls latest changes
4. ✅ Reads version from `VERSION` file
5. ✅ Determines build number (from pre-release or manual input)
6. ✅ Generates changelog from commits
7. ✅ Updates `CHANGELOG.md`
8. ✅ Creates and pushes tag
9. ✅ Creates GitHub release
10. ✅ Updates major version tag

#### Example Session

```bash
$ ./release.sh 45

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Official Release Creator
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[INFO] Pulling latest changes from origin...
[INFO] Version from VERSION file: 1.0
[INFO] Using provided build number: 45
[INFO] Release version: v1.0.45
[INFO] This will be the first official release
[INFO] Generating changelog...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Release Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Version:      v1.0.45
  Build Number: 45
  Branch:       main
  Commit:       a3f2b1c

Continue with release? (y/N)
```

### Method 2: GitHub Actions Workflow

Trigger manually from GitHub UI:

1. Go to **Actions** → **Manual Release Workflow**
2. Click **Run workflow**
3. Enter the build number (e.g., `45`)
4. Click **Run workflow**

⚠️ **Note**: The local script is preferred as it provides better control and feedback.

## Versioning Strategy

### Bumping Major.Minor Version

Use the `bump-version.sh` script to bump major or minor versions:

```bash
# Bump minor version (1.0 → 1.1)
./bump-version.sh minor

# Bump major version (1.x → 2.0)
./bump-version.sh major
```

This creates an initial release with the new version (e.g., `v1.1.1` or `v2.0.1`).

After bumping:
- Next pre-release: `v1.1.46-xyz789`
- Next official release: `v1.1.46`

**How it works:** The version is derived from git tags, not a file. The latest official release tag determines the current `major.minor` version.

### Major Version Tags

The system automatically maintains major version tags (`v1`, `v2`, etc.):

- Always points to the latest release in that major version
- Allows users to auto-update: `uses: LiquidLogicLabs/docker-ca-certificate@v1`

## Changelog Management

### Automatic Generation

Changelogs are auto-generated from git commits:

- **Pre-releases**: Include all commits since last official release
- **Official releases**: Include all commits since last official release

### Best Practices for Commit Messages

Use conventional commit format for better changelogs:

```bash
feat: Add support for certificate bundles
fix: Correct validation for multi-cert files
docs: Update troubleshooting guide
chore: Cleanup old pre-release tags
```

### Manual CHANGELOG.md

The `CHANGELOG.md` file is automatically updated when creating releases.

Format:
```markdown
## [Unreleased]

## [1.0.45] - 2024-10-14
- Enhanced debug logging with colored output
- Added certificate preview in debug mode
- Fixed file size detection for cross-platform support

## [1.0.44] - 2024-10-13
- Initial release with basic functionality
```

## Complete Workflow Example

### Day-to-Day Development

```bash
# Make changes
git add .
git commit -m "feat: Add certificate validation"
git push origin main

# ✅ Automatic pre-release created: v1.0.45-a3f2b1c
```

### When Ready for Production

```bash
# Test the pre-release in your environment
# uses: LiquidLogicLabs/docker-ca-certificate@v1.0.45-a3f2b1c

# If everything works, create official release
./release.sh 45

# ✅ Official release created: v1.0.45
# ✅ Major version tag updated: v1
```

### Bumping to New Minor Version

```bash
# Ready for new features
echo "1.1" > VERSION
git add VERSION
git commit -m "chore: Bump version to 1.1"
git push origin main

# Next push creates: v1.1.46-xyz789
```

## Troubleshooting

### "No pre-release found to extract build number"

You need to specify the build number manually:

```bash
./release.sh 1
```

### "Tag already exists"

The release for this build number already exists. Use a different build number or delete the existing tag.

### "GitHub CLI (gh) not found"

Install the GitHub CLI for automatic release creation:

```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

Then authenticate:

```bash
gh auth login
```

### Pre-releases Not Being Created

Check:
1. You pushed to `main` or `develop` branch
2. Tests passed (check GitHub Actions)
3. You have write permissions to the repository

## CI/CD Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Developer Workflow                                              │
│                                                                  │
│  git commit → git push → GitHub Actions                          │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  1. Run Tests                                               │ │
│  │     • Local file test                                       │ │
│  │     • URL download test                                     │ │
│  │     • Inline content test                                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                           │                                      │
│                           ▼                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  2. Create Pre-Release (if tests pass)                     │ │
│  │     • Version: major.minor.build-sha                        │ │
│  │     • Generate changelog from commits                       │ │
│  │     • Tag as pre-release                                    │ │
│  │     • Clean up old pre-releases                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Manual Release (when ready for production):                    │
│                                                                  │
│  ./release.sh → Tests → Official Release                        │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  3. Create Official Release                                 │ │
│  │     • Version: major.minor.build                            │ │
│  │     • Update CHANGELOG.md                                   │ │
│  │     • Create GitHub release                                 │ │
│  │     • Update major version tag                              │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Reference

| Task | Command | Result |
|------|---------|--------|
| Make changes | `git push origin main` | Auto pre-release `v1.0.45-abc123` |
| Create release | `./release.sh` | Official release `v1.0.45` |
| Create release (specific) | `./release.sh 45` | Official release `v1.0.45` |
| Bump minor version | `echo "1.1" > VERSION && git push` | Next: `v1.1.46-xyz` |
| Bump major version | `echo "2.0" > VERSION && git push` | Next: `v2.0.1-xyz` |

## Best Practices

1. ✅ **Test pre-releases** before promoting to official release
2. ✅ **Use semantic commit messages** for better changelogs
3. ✅ **Update VERSION file** when bumping major/minor versions
4. ✅ **Review changelog** before releasing
5. ✅ **Use major version tags** for user convenience (`@v1`)
6. ✅ **Keep CHANGELOG.md** up to date with notable changes

