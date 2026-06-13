# Winget Submission Guide

## Prerequisites
- Windows 10 build 17763 or later
- `winget` installed (comes with App Installer)
- `wingetcreate` installed: `winget install wingetcreate`
- GitHub account

## Step 1: Compute SHA256 of Release Zip

```powershell
Get-FileHash .\Forgum-v1.0.3.zip -Algorithm SHA256
```

## Step 2: Update Installer Manifest

Update `package-managers/winget/HKDEVS.Forgum.installer.yaml`:
- Replace hash with the actual SHA256 hash
- Update `InstallerUrl` to the actual release URL

## Step 3: Validate Manifest

```powershell
winget validate package-managers\winget\
```

## Step 4: Test in Windows Sandbox

```powershell
git clone https://github.com/microsoft/winget-pkgs
cd winget-pkgs
powershell .\Tools\SandboxTest.ps1 ..\HKDEVS\Forgum\1.0.3\
```

## Step 5: Fork and Submit

1. Fork https://github.com/microsoft/winget-pkgs
2. Clone your fork with sparse checkout:
   ```powershell
   git clone --filter=blob:none --no-checkout https://github.com/YOUR_USERNAME/winget-pkgs
   cd winget-pkgs
   git sparse-checkout set manifests\h\HKDEVS
   git checkout
   ```
3. Copy all 3 manifests from `package-managers/winget/` to `manifests/h/HKDEVS/Forgum/1.0.3/`
4. Commit and push:
   ```powershell
   git add .
   git commit -m "Add HKDEVS.Forgum v1.0.3"
   git push
   ```
5. Create PR to `microsoft/winget-pkgs` main branch

## Step 6: Monitor PR

Watch for labels:
- `Azure-Pipeline-Passed` — automated tests passed
- `Validation-Completed` — approved and merged
- `Needs-Author-Feedback` — fix required

## Troubleshooting

| Label | Action |
|-------|--------|
| `Error-Hash-Mismatch` | Recompute SHA256, update manifest |
| `Validation-Unattended-Failed` | Ensure installer supports `/VERYSILENT` |
| `Validation-Domain` | Ensure InstallerUrl is from GitHub directly |
| `Binary-Validation-Error` | Check for false positive with antivirus |
