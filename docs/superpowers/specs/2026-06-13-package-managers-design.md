# Forgum Package Manager Distribution — Design Spec

**Date:** 2026-06-13
**Status:** Draft
**Author:** opencode

## Overview

Add Forgum to Windows Package Manager (winget) and Scoop, with an interactive setup script that configures terminal shell integration. Document the submission process in `.agent/`.

## Goals

1. Users can install Forgum via `winget install HKDEVS.Forgum`
2. Users can install Forgum via `scoop install hkdevs/forgum`
3. Interactive installer asks for shell configuration toggles
4. Silent install mode for package managers (all defaults enabled)
5. Documentation covers submission process and architecture

## Components

### 1. Interactive Setup Script (`setup.ps1`)

**Location:** Project root (alongside `install.ps1`)

**Purpose:** Configure Forgum shell integration after module is installed.

**Parameters:**
- `-NonInteractive` — Skip all prompts, use defaults (for winget/scoop)
- `-Force` — Overwrite existing config without asking
- `-NoProfile` — Don't modify PowerShell profile

**Interactive Toggles (6 total):**

| Toggle | Default | Description |
|--------|---------|-------------|
| Fortune cow on startup | `$true` | Add `Show-FortuneCow` to profile |
| Lolcat rainbow enabled | `$true` | Set `lolcat.enabled = $true` in config |
| Default cow file | `'default'` | Set `cow.file` in config (show list of popular cows) |
| Animation mode | `'static'` | Set `animation.mode` in config |
| Shell aliases | `$true` | Add `cowconfig`, `cowpreview`, `cowgallery`, etc. to profile |
| Tab completion | `$true` | Register `Register-ArgumentCompleter` for Forgum commands |

**Flow:**
```
1. Check if Forgum module is installed
2. If not → error, tell user to run install.ps1 first
3. Load current config via Get-CFConfig
4. If -NonInteractive → skip to step 7
5. Show current settings, ask to change each toggle
6. Apply changes via Set-CFConfig
7. Update PowerShell profile ($PROFILE.CurrentUserAllHosts)
8. Show summary of changes
```

**Profile Changes:**
- Add `Import-Module Forgum` if not present
- Add `Show-FortuneCow` call in startup block (guarded by `-not $global:HKDEVS_STARTUP_DONE`)
- Add alias definitions if enabled
- Add tab completion block if enabled

### 2. Winget Manifest

**PackageIdentifier:** `HKDEVS.Forgum`
**Publisher:** `HKDEVS`
**PackageName:** `Forgum`

**Manifest Structure (multi-file format):**

```
manifests/h/HKDEVS/Forgum/1.0.3/
├── HKDEVS.Forgum.yaml          # version file
├── HKDEVS.Forgum.locale.en-US.yaml  # default locale
└── HKDEVS.Forgum.installer.yaml     # installer
```

**Installer Config:**
- `InstallerType`: `powerShell`
- `InstallerUrl`: `https://github.com/harish2222/Forgum/releases/download/v1.0.3/Forgum-v1.0.3.zip`
- `InstallerSha256`: (computed from release zip)
- `InstallerSwitches.Silent`: `-NonInteractive -Force`
- `InstallerSwitches.SilentWithProgress`: `-NonInteractive`

**Install Behavior:**
1. Download and extract zip to temp directory
2. Copy module to `~/Documents/PowerShell/Modules/Forgum/`
3. Run `setup.ps1 -NonInteractive -Force`
4. Module immediately available in new PowerShell sessions

### 3. Scoop Manifest

**Bucket:** `hkdevs/forgum` (own bucket repo)

**Manifest:** `bucket/forgum.json`

```json
{
  "version": "1.0.3",
  "description": "Cowsay + Fortune + Lolcat PowerShell module",
  "homepage": "https://github.com/harish2222/Forgum",
  "license": "MIT",
  "url": "https://github.com/harish2222/Forgum/releases/download/v1.0.3/Forgum-v1.0.3.zip",
  "hash": "<sha256>",
  "powershell": {
    "ver": "5.1"
  },
  "install": [
    "Copy-Item -Path \"$dir\\Forgum\" -Destination \"$env:USERPROFILE\\Documents\\PowerShell\\Modules\\Forgum\" -Recurse -Force",
    "& \"$dir\\setup.ps1\" -NonInteractive -Force"
  ],
  "uninstall": [
    "Remove-Item -Path \"$env:USERPROFILE\\Documents\\PowerShell\\Modules\\Forgum\" -Recurse -Force -ErrorAction SilentlyContinue"
  ]
}
```

**ScoopExtras Submission:**
After own bucket works, create PR to `ScoopInstaller/Extras` with the same manifest.

### 4. Documentation

**Files to create in `.agent/`:**

| File | Content |
|------|---------|
| `winget-submission-guide.md` | Step-by-step: fork winget-pkgs, create manifest, validate, submit PR, troubleshoot |
| `scoop-submission-guide.md` | Step-by-step: create bucket repo, add manifest, test, submit to Extras |
| `installer-architecture.md` | Technical design of setup.ps1, flow diagrams, profile modification logic |

### 5. Changes to Existing Files

| File | Change |
|------|--------|
| `Forgum.psd1` | Update version to `1.0.3`, update ReleaseNotes |
| `install.ps1` | Add `-Silent` flag that runs `setup.ps1 -NonInteractive` after install |
| `ci.yml` | Add build job to create release zip with setup.ps1 included |
| `README.md` | Add winget/scoop install instructions |

## File Structure After Implementation

```
D:\Projects\Forgum\
├── setup.ps1                    # NEW — interactive setup script
├── install.ps1                  # MODIFIED — add -Silent flag
├── install.sh                   # UNCHANGED
├── uninstall.ps1                # UNCHANGED
├── .agent/
│   ├── winget-submission-guide.md    # NEW
│   ├── scoop-submission-guide.md     # NEW
│   ├── installer-architecture.md     # NEW
│   └── ... (existing files)
├── docs/superpowers/specs/
│   └── 2026-06-13-package-managers-design.md  # THIS FILE
└── ... (other existing files)
```

## Submission Workflow

### Winget (microsoft/winget-pkgs)

1. Compute SHA256 of release zip
2. Create manifest files in `manifests/h/HKDEVS/Forgum/1.0.3/`
3. Validate: `winget validate manifests/h/HKDEVS/Forgum/1.0.3/`
4. Test in sandbox: `.\Tools\SandboxTest.ps1 manifests/h/HKDEVS/Forgum/1.0.3/`
5. Fork `microsoft/winget-pkgs`, push branch, create PR
6. Wait for automated validation + manual review

### Scoop (own bucket)

1. Create `hkdevs/forgum` GitHub repo
2. Add `bucket/forgum.json` manifest
3. Test: `scoop install hkdevs/forgum`
4. Later: submit PR to `ScoopInstaller/Extras`

## Testing Plan

1. **Unit test setup.ps1**: Test each toggle in isolation
2. **Integration test**: Run `setup.ps1 -NonInteractive` on clean environment
3. **Winget test**: Validate manifest, test in Windows Sandbox
4. **Scoop test**: Install from own bucket, verify module loads
5. **Existing tests**: All 127 Pester tests must still pass

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Winget review takes weeks | Submit early, iterate on feedback |
| Scoop manifest SHA256 mismatch | Pin to specific release URL, not vanity URL |
| Profile modification breaks user setup | Guard with existence checks, backup before modify |
| Silent install fails on locked profiles | Try `$PROFILE.CurrentUserAllHosts` first, fall back to `$PROFILE.CurrentUser` |
