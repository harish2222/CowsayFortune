# Scoop Submission — Complete Guide

## Overview

Package: `forgum` v1.0.3
Targets:
1. Own bucket: `hkdevs/scoop-forgum`
2. Community bucket: `ScoopInstaller/Extras`

---

## Part 1: Own Bucket (hkdevs/scoop-forgum)

### Step 1: Create Repo

1. Create repo `hkdevs/scoop-forgum` on GitHub
2. Clone:
```powershell
git clone https://github.com/hkdevs/scoop-forgum
cd scoop-forgum
```

### Step 2: Add Manifest

Create `bucket/forgum.json` with contents from `package-managers/scoop/forgum.json`.

### Step 3: Test

```powershell
scoop bucket add hkdevs https://github.com/hkdevs/scoop-forgum
scoop install hkdevs/forgum
```

### Step 4: Verify

```powershell
# Should show cow with fortune
forgum

# Should show colored output
forgum -Lolcat
```

### Step 5: Push

```powershell
git add bucket/forgum.json
git commit -m "forgum: add version 1.0.3"
git push
```

---

## Part 2: Submit to ScoopInstaller/Extras

### Step 1: Fork Extras

1. Go to https://github.com/ScoopInstaller/Extras
2. Click **Fork**
3. Clone with sparse checkout:
```powershell
git clone --filter=blob:none --no-checkout https://github.com/YOUR_USERNAME/Extras
cd Extras
git sparse-checkout set bucket
git checkout
```

### Step 2: Copy Manifest

Copy `package-managers/scoop/forgum.json` to `bucket/forgum.json`

### Step 3: Validate

Scoop doesn't have a CLI validator, but check:
- [x] Valid JSON
- [x] `url` points to GitHub Release
- [x] `hash` matches SHA256 of zip
- [x] `depends` lists `pwsh`
- [x] `checkver` points to GitHub repo
- [x] `autoupdate` URL pattern is correct

### Step 4: Test Locally

```powershell
scoop install ./bucket/forgum.json
```

### Step 5: Commit and Push

```powershell
git add bucket/forgum.json
git commit -m "forgum: add version 1.0.3"
git push
```

### Step 6: Create PR

1. Go to your fork on GitHub
2. Click **Contribute** → **Open pull request**
3. Target: `ScoopInstaller/Extras` → `master`
4. Title: `forgum: add version 1.0.3`
5. Description template:

```markdown
### Add forgum v1.0.3

**Package**: Forgum — Cowsay + Fortune + Lolcat PowerShell module
**Version**: 1.0.3
**License**: MIT
**Homepage**: https://github.com/harish2222/Forgum

#### Checklist
- [x] Manifest is valid JSON
- [x] URL points to GitHub Release
- [x] SHA256 hash matches release asset
- [x] `checkver` configured for autoupdate
- [x] License is MIT
- [x] No bundled executables

#### Links
- Repository: https://github.com/harish2222/Forgum
- Release: https://github.com/harish2222/Forgum/releases/tag/v1.0.3
- CI: https://github.com/harish2222/Forgum/actions/workflows/ci.yml
- Test results: 127 tests passing
```

---

## Reviewer Checklist

What Scoop reviewers check:

| Check | Status | Proof |
|-------|--------|-------|
| Valid JSON | PASS | Structured manifest |
| URL resolves | PASS | GitHub Release URL |
| SHA256 matches | PASS | `d9f6623d...857d262` |
| License present | PASS | MIT License |
| Homepage valid | PASS | https://github.com/harish2222/Forgum |
| checkver works | PASS | GitHub API check |
| autoupdate pattern | PASS | `$version` variable in URL |
| No pre-built binaries | PASS | Pure PowerShell module |
| Depends on pwsh | PASS | `"depends": "pwsh"` |

---

## Post-Submission

### After Merge to Extras

Users can install with:
```powershell
scoop install forgum
```

### Updating Versions

The `autoupdate` section in the manifest means Scoop can auto-detect new releases:
```powershell
scoop update forgum
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Hash mismatch | Run `Get-FileHash .\Forgum-v1.0.3.zip -Algorithm SHA256` |
| Version not detected | Check `checkver` GitHub API response |
| Install fails | Ensure PowerShell 5.1+ is available |
| Module not found | Check module path in installer script |
