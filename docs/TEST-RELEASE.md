# Testing the Release System

Before doing your first production release, test the automation:

## Local Testing

### 1. Test Version Calculation

```bash
# Dry run - see what would happen
git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"

# This shows your current version
# First release will be v1.0.0 (or v0.1.0 for minor)
```

### 2. Test the Script (Without Releasing)

```bash
# Read through the script to understand what it does
cat bump-version.sh

# The script will:
# 1. Show you what it will do
# 2. Ask for confirmation before each step
# 3. You can cancel at any time with Ctrl+C or "N"
```

### 3. Test CHANGELOG Update

```bash
# Make sure you have an [Unreleased] section
grep "Unreleased" CHANGELOG.md

# If not, add it:
# ## [Unreleased]
# 
# ### Added
# - Initial release
```

## GitHub Actions Testing

### 1. Test Workflow Syntax

```bash
# Install act (for local testing)
# macOS: brew install act
# Linux: see https://github.com/nektos/act

# Test the release workflow locally
act -W .github/workflows/release.yml -l

# This lists the jobs without running them
```

### 2. Test Tag Creation (Safe)

```bash
# Create a test tag (doesn't trigger release yet)
git tag -a v0.0.1-test -m "Test tag"

# Check it exists
git tag -l

# Delete it (cleanup)
git tag -d v0.0.1-test
```

## First Real Release - Checklist

Before running `./bump-version.sh major` for v1.0.0:

- [ ] All tests passing (`.github/workflows/test.yml`)
- [ ] CHANGELOG.md has [Unreleased] section with content
- [ ] README.md is complete
- [ ] action.yml is correct
- [ ] install-certificate.sh is tested and working
- [ ] No uncommitted changes (`git status`)
- [ ] On main branch
- [ ] Latest code pulled (`git pull`)

## Test Release Process

### Option 1: Test with v0.1.0 First

```bash
# Release a minor version first to test
./bump-version.sh minor

# This creates v0.1.0
# Test that:
# - GitHub Actions runs
# - Release is created
# - Major tag (v0) is created
# - Everything works

# Then do real v1.0.0 release later
```

### Option 2: Use Pre-release

```bash
# Create a pre-release manually
git tag -a v1.0.0-rc.1 -m "Release candidate 1"
git push origin v1.0.0-rc.1

# Check GitHub Actions creates it as pre-release
# Test using the action with @v1.0.0-rc.1
```

## Validation Checks

After your first release, verify:

### 1. GitHub Release Created
```
✓ Go to: https://github.com/ravensorb/actions/releases
✓ Release should be listed
✓ Changelog notes should be included
✓ Release assets (if any) should be present
```

### 2. Tags Created
```bash
# Check tags exist
git fetch --tags
git tag -l

# Should show:
# v1.0.0 (specific version)
# v1 (major version)
```

### 3. Action Works
```yaml
# Test in a workflow
- uses: ravensorb/actions/docker-certificate@v1.0.0
  with:
    certificate-source: 'test.crt'

# And with major version
- uses: ravensorb/actions/docker-certificate@v1
  with:
    certificate-source: 'test.crt'
```

### 4. Major Tag Auto-Updates

After releasing v1.0.1:
```bash
# Fetch tags
git fetch --tags

# v1 should point to v1.0.1 now
git show-ref v1
git show-ref v1.0.1
# Both should show the same commit SHA
```

## Rollback Plan

If something goes wrong:

### Delete a Release
```bash
# 1. Delete GitHub Release (GitHub UI)
# 2. Delete tags
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
git tag -d v1
git push origin :refs/tags/v1 --force

# 3. Fix the issue
# 4. Try again
```

### Revert CHANGELOG
```bash
git log --oneline  # Find commit before release
git revert <commit-sha>
# Or
git reset --hard <commit-sha>
git push origin main --force  # Use with caution!
```

## Production Release Checklist

When ready for v1.0.0:

```bash
# 1. Final review
git status
git log --oneline -5

# 2. Update CHANGELOG.md under [Unreleased]
# Add all changes since last version

# 3. Run release
./bump-version.sh major

# 4. Monitor
# Watch: https://github.com/ravensorb/actions/actions

# 5. Verify
# Check release appears
# Test action with @v1 and @v1.0.0
# Update your own workflows to use it

# 6. Announce
# Update dependent projects
# Post in team channels
# Update documentation
```

## Common Issues During Testing

### "No previous tag found"
✓ Normal for first release
✓ Script defaults to v0.0.0

### "CHANGELOG section not found"
✓ Add `## [Unreleased]` section
✓ Add at least one change item

### "GitHub Actions didn't run"
✓ Check repo settings → Actions → enabled
✓ Check workflow permissions
✓ Verify tag was pushed: `git ls-remote --tags origin`

### "Major tag not updated"
✓ Check GitHub Actions workflow logs
✓ Ensure bot has write permissions
✓ May need to configure repository token permissions

## Success Criteria

Your release system is working when:

- ✅ One command creates full release
- ✅ GitHub release has changelog notes
- ✅ Both v1.0.0 and v1 tags exist
- ✅ Action works when referenced by both tags
- ✅ Future releases update v1 automatically
- ✅ No manual steps required

🎉 **You're ready to release!**

