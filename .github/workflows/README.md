# GitHub Actions Workflows

This directory contains the CI/CD workflows for the Docker CA Certificate Action.

## Workflows

### `ci-pre-release.yml` - The Only Workflow You Need

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`

**What it does:**
1. **Test Suite** - Runs comprehensive tests:
   - Local file installation
   - URL download
   - Inline certificate content
   - Debug mode validation

2. **Pre-Release Creation** (only on push to main/develop, not on PRs):
   - Generates version: `v{major}.{minor}.{build}-{sha}`
   - Creates changelog from commits since last release
   - Creates GitHub pre-release
   - Cleans up old pre-releases (keeps last 10)

**Example output:** `v1.0.45-a3f2b1c`

### Official Releases - Use Local Script

For official releases, use the `release.sh` script instead of a workflow:

```bash
./release.sh [build_number]
```

**Why no workflow?**
- ✅ Local script is faster (no waiting for GitHub Actions)
- ✅ Better control (review before pushing)
- ✅ Better UX (colored output, prompts, previews)
- ✅ More reliable (works offline, better error handling)
- ✅ Simpler architecture (fewer moving parts)

## Versioning

### Version Source
Versions are derived from **git tags**. The system examines the latest official release tag to determine the current `major.minor` version.

To bump versions:
```bash
# Bump minor version (1.0 → 1.1)
./bump-version.sh minor

# Bump major version (1.x → 2.0)
./bump-version.sh major
```

This creates an initial release with the new version (e.g., `v1.1.1` or `v2.0.1`).

### Build Numbers
Build numbers come from GitHub Actions run number, ensuring unique, sequential builds.

### Version Formats

| Type | Format | Example | Created By |
|------|--------|---------|------------|
| Pre-Release | `v{major}.{minor}.{build}-{sha}` | `v1.0.45-a3f2b1c` | Automatic on push |
| Official Release | `v{major}.{minor}.{build}` | `v1.0.45` | Manual via `release.sh` |
| Major Version Tag | `v{major}` | `v1` | Automatic (points to latest) |

## Permissions

Workflows require:
- `contents: write` - To create tags and releases

Ensure the `GITHUB_TOKEN` has appropriate permissions in repository settings.

## Secrets

No secrets are required for basic operation. All workflows use the default `GITHUB_TOKEN`.

## Local Testing

Use the `release.sh` script for local release creation:

```bash
# Create release from latest pre-release
./release.sh

# Or specify build number
./release.sh 45
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         CI/CD Flow                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Developer Push to main/develop                              │
│           ↓                                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  GitHub Actions: ci-pre-release.yml                    │ │
│  │  1. Run Tests                                          │ │
│  │  2. Create Pre-Release (if tests pass)                │ │
│  │     → v1.0.45-a3f2b1c                                  │ │
│  └────────────────────────────────────────────────────────┘ │
│           ↓                                                  │
│  Test pre-release in staging                                 │
│           ↓                                                  │
│  When ready for production:                                  │
│           ↓                                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Local: ./release.sh 45                                │ │
│  │  1. Validate environment                               │ │
│  │  2. Generate changelog                                 │ │
│  │  3. Create official release                            │ │
│  │     → v1.0.45                                          │ │
│  │  4. Update major tag                                   │ │
│  │     → v1 → v1.0.45                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Philosophy:** Keep CI/CD simple. One workflow for automation, one script for manual releases.

## Troubleshooting

### Workflow Not Triggering

Check:
1. You pushed to `main` or `develop`
2. Workflow file is in `.github/workflows/`
3. YAML syntax is valid
4. Repository permissions allow Actions

### Pre-Release Not Created

Check:
1. Tests passed (see Actions tab)
2. You have write permissions
3. `GITHUB_TOKEN` has `contents: write` permission

### Release Failed

Check:
1. Version tag doesn't already exist
2. VERSION file exists and is valid
3. No uncommitted changes
4. You're on `main` branch

## Documentation

For detailed usage:
- [Complete Release Workflow Guide](../../docs/RELEASE-WORKFLOW.md)
- [Quick Start Guide](../../docs/QUICK-START-RELEASE.md)

## Contact

For issues or questions about the workflow:
- Open an issue in the repository
- Check existing documentation
- Review workflow logs in Actions tab

