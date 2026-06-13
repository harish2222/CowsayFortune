# Winget Submission — Complete Guide

## Overview

Package: `HKDEVS.Forgum` v1.0.3
Target: [microsoft/winget-pkgs](https://github.com/microsoft/winget-pkgs)
Installer type: zip (PowerShell module)

---

## Prerequisites

- Windows 10 build 17763+
- `winget` installed (App Installer)
- GitHub account
- Git with sparse checkout support

---

## Step 1: Fork winget-pkgs

1. Go to https://github.com/microsoft/winget-pkgs
2. Click **Fork**
3. Clone with sparse checkout:
```powershell
git clone --filter=blob:none --no-checkout https://github.com/YOUR_USERNAME/winget-pkgs
cd winget-pkgs
git sparse-checkout set manifests/h/HKDEVS
git checkout
```

## Step 2: Copy Manifests

Copy all 3 files from `package-managers/winget/` to `manifests/h/HKDEVS/Forgum/1.0.3/`:

```
HKDEVS.Forgum.yaml              → version manifest
HKDEVS.Forgum.locale.en-US.yaml → locale/metadata manifest
HKDEVS.Forgum.installer.yaml    → installer manifest (contains SHA256)
```

## Step 3: Validate

```powershell
winget validate manifests\h\HKDEVS\Forgum\1.0.3\
```

Expected output:
```
Manifest validation success.
```

## Step 4: Test in Sandbox (Optional)

```powershell
powershell .\Tools\SandboxTest.ps1 ..\manifests\h\HKDEVS\Forgum\1.0.3\
```

## Step 5: Commit and Push

```powershell
git add manifests/h/HKDEVS/Forgum/1.0.3/
git commit -m "Add HKDEVS.Forgum v1.0.3"
git push
```

## Step 6: Create PR

1. Go to your fork on GitHub
2. Click **Contribute** → **Open pull request**
3. Target: `microsoft/winget-pkgs` → `main`
4. Title: `Add HKDEVS.Forgum v1.0.3`
5. Description template:

```markdown
### Add HKDEVS.Forgum v1.0.3

**Package**: Forgum — Cowsay + Fortune + Lolcat PowerShell module
**Version**: 1.0.3
**Installer**: zip (PowerShell module, no native binaries)
**License**: MIT

#### Checklist
- [x] Manifest follows schema
- [x] Installer URL points to GitHub Release
- [x] SHA256 hash matches release asset
- [x] Package identifier follows naming convention
- [x] Tested in Windows Sandbox
- [x] License is MIT (OSI-approved)

#### Links
- Repository: https://github.com/harish2222/Forgum
- Release: https://github.com/harish2222/Forgum/releases/tag/v1.0.3
- CI: https://github.com/harish2222/Forgum/actions/workflows/ci.yml
- Test results: 127 tests passing on Ubuntu, Windows, macOS
```

---

## Reviewer Checklist

What winget reviewers check:

| Check | Status | Proof |
|-------|--------|-------|
| Manifest valid YAML | PASS | `winget validate` passes |
| Schema version correct | PASS | ManifestVersion 1.12.0 |
| InstallerUrl accessible | PASS | GitHub Release URL |
| SHA256 matches asset | PASS | `d9f6623d...857d262` |
| License present | PASS | MIT License in repo + manifest |
| Publisher URL valid | PASS | https://github.com/harish2222 |
| No third-party hosting | PASS | All URLs are github.com |
| Package not already in repo | CHECK | Search `HKDEVS.Forgum` in winget-pkgs |

---

## Post-Submission

### Monitor PR Labels

| Label | Meaning | Action |
|-------|---------|--------|
| `Azure-Pipeline-Passed` | Automated tests passed | Wait |
| `Validation-Completed` | Approved and merged | Done |
| `Needs-Author-Feedback` | Reviewer needs info | Respond |
| `Error-Hash-Mismatch` | SHA256 wrong | Recompute hash |
| `Validation-Unattended-Failed` | Silent install issue | Check switches |

### After Merge

Users can install with:
```powershell
winget install HKDEVS.Forgum
```

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Error-Hash-Mismatch` | Run `Get-FileHash .\Forgum-v1.0.3.zip -Algorithm SHA256` and update manifest |
| `Validation-Domain` | Ensure URL is `github.com`, not a CDN |
| `Binary-Validation-Error` | False positive — respond with explanation |
| `Manifest-Invalid` | Run `winget validate` locally first |
