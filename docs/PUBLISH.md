# Publishing This Action to GitHub

## Quick Publish Guide

### Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `docker-ca-certificate`
3. Description: `GitHub Action for installing custom certificates in Docker build environments`
4. Public repository
5. **Don't** initialize with README (we have one)
6. Click "Create repository"

### Step 2: Connect & Push

```bash
# Navigate to action directory
cd /home/ravenwolf.org/sanderson/source/git/LiquidLogicLabs/docker-ca-certificate

# Initialize git (if not done)
git init

# Add all files
git add .

# Initial commit
git commit -m "feat: Initial release - Docker Certificate Action

- Install custom certificates from file, URL, or inline content
- Automatic system CA trust store integration
- Works with Docker registry authentication
- Comprehensive error handling and validation"

# Add GitHub remote
git remote add origin https://github.com/LiquidLogicLabs/docker-ca-certificate.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Create First Release

```bash
# Use the automated release script
./bump-version.sh major

# This will:
# - Create tag v1.0.0
# - Update CHANGELOG
# - Push tag to GitHub
# - Trigger GitHub Actions to create release
# - Set up v1 major version tag
```

### Step 4: Verify

1. **Check repository:** https://github.com/LiquidLogicLabs/docker-ca-certificate
2. **Check release:** https://github.com/LiquidLogicLabs/docker-ca-certificate/releases
3. **Check tags:** Should see both `v1.0.0` and `v1`

### Step 5: Test in Another Workflow

Create a test workflow in any repository:

```yaml
name: Test Action

on: [push]

jobs:
  test:
    runs-on: ubuntu-22.04
    steps:
      - name: Test certificate action
        uses: LiquidLogicLabs/docker-ca-certificate@v1
        with:
          certificate-source: 'https://curl.se/ca/cacert.pem'
          certificate-name: 'test.crt'
          debug: true
```

## Repository Settings

After publishing, configure these settings:

### General Settings
- ✅ Description: "GitHub Action for installing custom certificates in Docker builds"
- ✅ Topics: `github-actions`, `docker`, `certificates`, `ssl`, `tls`, `devops`
- ✅ Website: Link to docs if you have them

### Actions Permissions
1. Go to: Settings → Actions → General
2. Workflow permissions: "Read and write permissions"
3. Allow GitHub Actions to create and approve pull requests: ✅

### Branch Protection (Optional but Recommended)
1. Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require pull request reviews before merging
   - ✅ Require status checks to pass before merging
   - ✅ Include administrators

## GitHub Marketplace (Optional)

To publish to GitHub Marketplace:

### Step 1: Add Marketplace Metadata to action.yml

```yaml
# Add these fields to action.yml
branding:
  icon: 'shield'      # Already have this ✅
  color: 'blue'       # Already have this ✅

# Author field (add if not present)
author: 'LiquidLogicLabs'
```

### Step 2: Publish to Marketplace

1. Go to your repository
2. Click on "Releases"
3. Click "Draft a new release"
4. Check ✅ "Publish this Action to the GitHub Marketplace"
5. Fill in category: "Deployment"
6. Add tags: docker, ssl, certificates
7. Publish

## Update Documentation

After publishing, update references in docs:

### In README.md

```yaml
# Current examples use:
uses: LiquidLogicLabs/docker-ca-certificate@v1

# Change to:
uses: LiquidLogicLabs/docker-ca-certificate@v1
```

### In EXAMPLES.md

Update all usage examples to use the correct repository path.

## Complete Checklist

Before publishing:
- [ ] All tests pass (`.github/workflows/ci-pre-release.yml`)
- [ ] CHANGELOG.md is up to date
- [ ] README.md is complete
- [ ] No sensitive data in files
- [ ] LICENSE file present ✅
- [ ] .gitignore configured ✅

During publishing:
- [ ] GitHub repository created
- [ ] Git remote added
- [ ] Initial commit pushed
- [ ] First release created (v1.0.0)
- [ ] Major version tag exists (v1)

After publishing:
- [ ] Test action in another workflow
- [ ] Verify both @v1 and @v1.0.0 work
- [ ] Update dependent projects
- [ ] Consider publishing to Marketplace
- [ ] Share with team/community

## Maintenance After Publishing

### Making Updates

```bash
# 1. Make changes to code
# 2. Update CHANGELOG.md under [Unreleased]
# 3. Release new version
./bump-version.sh patch   # or minor/major

# GitHub Actions automatically:
# - Creates release
# - Updates v1 tag
# - Users on @v1 get updates automatically
```

### Versioning Strategy

- **Patch** (1.0.0 → 1.0.1): Bug fixes, no breaking changes
- **Minor** (1.0.0 → 1.1.0): New features, no breaking changes
- **Major** (1.0.0 → 2.0.0): Breaking changes

Users on `@v1` get patches and minor updates automatically.
Users on `@v1.0.0` never get updates (pinned).

## Support & Community

### Add GitHub Templates

```bash
# Create issue templates
mkdir -p .github/ISSUE_TEMPLATE

# Create pull request template
echo "..." > .github/PULL_REQUEST_TEMPLATE.md

# Add to next commit
```

### Enable Discussions

Settings → Features → ✅ Discussions

### Security Policy

Create `SECURITY.md` with vulnerability reporting info.

## Ready to Publish?

Run these commands to publish right now:

```bash
# 1. Create repo on GitHub (do this first)
# Repository: docker-ca-certificate

# 2. Run these commands
cd /home/ravenwolf.org/sanderson/source/git/LiquidLogicLabs/docker-ca-certificate
git init
git add .
git commit -m "feat: Initial release - Docker Certificate Action"
git remote add origin https://github.com/LiquidLogicLabs/docker-ca-certificate.git
git branch -M main
git push -u origin main

# 3. Create first release
./bump-version.sh major

# 4. Done! Check:
# https://github.com/LiquidLogicLabs/docker-ca-certificate
```

