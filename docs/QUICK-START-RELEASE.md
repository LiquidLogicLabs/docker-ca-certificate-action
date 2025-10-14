# Quick Start: Release Process

This is a quick reference for creating releases. For detailed information, see [RELEASE-WORKFLOW.md](RELEASE-WORKFLOW.md).

## TL;DR

### Automatic Pre-Releases

Every push to `main` or `develop` automatically:
1. ✅ Runs all tests
2. 📦 Creates pre-release (e.g., `v1.0.45-a3f2b1c`)
3. 📝 Generates changelog

**You don't do anything - it's automatic!**

### Manual Official Releases

When you're ready to promote a pre-release to production:

```bash
./release.sh
```

That's it! The script will:
- ✅ Extract build number from latest pre-release
- ✅ Create official release (e.g., `v1.0.45`)
- ✅ Update changelog
- ✅ Update major version tag

## Version Numbers

### Pre-Release
Format: `v{major}.{minor}.{build}-{sha}`

Example: `v1.0.45-a3f2b1c`

- Automatically created on every push
- Tagged as pre-release
- Use for testing before production

### Official Release
Format: `v{major}.{minor}.{build}`

Example: `v1.0.45`

- Created manually with `./release.sh`
- Not tagged as pre-release
- Production-ready

## Common Tasks

### Create Release from Latest Pre-Release

```bash
./release.sh
```

### Create Release from Specific Build

```bash
./release.sh 45
```

### Bump Minor Version (1.0 → 1.1)

```bash
./bump-version.sh minor
```

Next pre-release will be: `v1.1.46-xyz789`

### Bump Major Version (1.x → 2.0)

```bash
./bump-version.sh major
```

Next pre-release will be: `v2.0.1-xyz789`

## Workflow Diagram

```
┌──────────────────────────────────────────────┐
│  Development                                  │
│                                               │
│  git commit -m "feat: Add new feature"       │
│  git push origin main                         │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│  Automatic (GitHub Actions)                   │
│                                               │
│  • Run tests                                  │
│  • Create pre-release: v1.0.45-a3f2b1c       │
│  • Generate changelog                         │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│  Test Pre-Release                             │
│                                               │
│  uses: LiquidLogicLabs/action@v1.0.45-a3f2b1c      │
│                                               │
│  ✅ Works? → Proceed                          │
│  ❌ Issues? → Fix & push again                │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│  Create Official Release                      │
│                                               │
│  ./release.sh                                 │
│                                               │
│  • Creates: v1.0.45                           │
│  • Updates major tag: v1                      │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│  Production Use                               │
│                                               │
│  uses: LiquidLogicLabs/action@v1.0.45              │
│  uses: LiquidLogicLabs/action@v1  (auto-updates)   │
└──────────────────────────────────────────────┘
```

## Version Management

### Version Source
Versions are derived from **git tags**, not files. The system looks at the latest official release tag to determine the current `major.minor` version.

### `CHANGELOG.md`
Automatically updated by release scripts.

Keep the `## [Unreleased]` section at the top for upcoming changes.

## Troubleshooting

### "No pre-release found to extract build number"

Specify build number manually:

```bash
./release.sh 1
```

### "Tag already exists"

That release already exists. Either:
- Use a different build number
- Delete the existing tag

### "You have uncommitted changes"

Commit or stash your changes first:

```bash
git add .
git commit -m "Your message"
git push origin main
# Then try again
./release.sh
```

### GitHub CLI Not Found

Install GitHub CLI for automatic release creation:

```bash
# macOS
brew install gh

# Linux
sudo apt install gh

# Authenticate
gh auth login
```

## Full Documentation

For complete details, see:
- [Complete Release Workflow Guide](RELEASE-WORKFLOW.md)
- [Local Testing](LOCAL-TESTING.md)
- [Troubleshooting](TROUBLESHOOTING.md)

## Quick Commands

| What | Command |
|------|---------|
| Create release from latest pre-release | `./release.sh` |
| Create release from specific build | `./release.sh 45` |
| Bump minor version | `./bump-version.sh minor` |
| Bump major version | `./bump-version.sh major` |
| View latest pre-release | `git tag --sort=-version:refname \| grep '-' \| head -n 1` |
| View latest release | `git tag --sort=-version:refname \| grep -v '-' \| head -n 1` |

