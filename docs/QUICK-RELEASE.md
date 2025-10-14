# Quick Release Guide

Three ways to release this action:

## 🚀 Method 1: Simple Local Command (Recommended)

**One command does everything:**

```bash
# Patch release (1.0.0 → 1.0.1) - bug fixes
./bump-version.sh patch

# Minor release (1.0.0 → 1.1.0) - new features
./bump-version.sh minor

# Major release (1.0.0 → 2.0.0) - breaking changes
./bump-version.sh major
```

**What it does:**
1. ✅ Auto-calculates next version
2. ✅ Updates CHANGELOG.md
3. ✅ Commits changes
4. ✅ Creates and pushes tag
5. ✅ Triggers GitHub Actions to create release
6. ✅ GitHub Actions updates major version tag (v1, v2, etc.)

**First time setup:**
```bash
chmod +x bump-version.sh
```

---

## 🌐 Method 2: GitHub UI (No Local Setup)

1. Go to: https://github.com/LiquidLogicLabs/actions/actions/workflows/manual-release.yml
2. Click "Run workflow"
3. Choose version bump type (patch/minor/major) OR enter specific version
4. Click "Run workflow"

**Done!** GitHub Actions handles everything.

---

## 🛠️ Method 3: Manual Process

If you prefer full control:

```bash
# 1. Update CHANGELOG.md manually
# 2. Commit changes
git add CHANGELOG.md
git commit -m "Release v1.0.1"
git push origin main

# 3. Create and push tag
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1

# GitHub Actions automatically:
# - Creates GitHub release
# - Updates major version tag
```

---

## 📋 Comparison

| Method | Speed | Setup | Control | Automation |
|--------|-------|-------|---------|------------|
| Local Script | ⚡⚡⚡ | 1 min | Medium | High |
| GitHub UI | ⚡⚡ | None | Low | Full |
| Manual | ⚡ | None | Full | Partial |

---

## 🎯 Recommended Workflow

**For regular development:**
```bash
./bump-version.sh patch
```

**For new features:**
```bash
./bump-version.sh minor
```

**For breaking changes:**
```bash
./bump-version.sh major
```

That's it! The script and GitHub Actions handle the rest.

---

## 🔍 What Happens Behind the Scenes

1. **Local script** (`bump-version.sh`):
   - Calculates new version
   - Updates CHANGELOG
   - Creates git tag
   - Pushes to GitHub

2. **GitHub Actions** (`.github/workflows/release.yml`):
   - Triggers on tag push
   - Extracts changelog
   - Creates GitHub release
   - Updates major version tag (v1, v2, etc.)

3. **Result**:
   - GitHub release created with changelog
   - Both specific (`v1.0.1`) and major (`v1`) tags updated
   - Users can reference: `@v1` or `@v1.0.1`

---

## 🆘 Troubleshooting

**"Permission denied" error:**
```bash
chmod +x bump-version.sh
```

**"Not on main branch" warning:**
The script ensures you're releasing from main. Switch branches or modify the script if needed.

**GitHub Actions not running:**
Check: https://github.com/LiquidLogicLabs/actions/actions

**Need to delete a release:**
```bash
# Delete tag locally and remotely
git tag -d v1.0.1
git push origin :refs/tags/v1.0.1

# Delete from GitHub UI:
# Go to releases, click the release, click "Delete"
```

