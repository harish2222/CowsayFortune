# Scoop Submission Guide

## Own Bucket (hkdevs/scoop-forgum)

### Step 1: Create GitHub Repo

1. Create repo `hkdevs/scoop-forgum` on GitHub
2. Clone it:
   ```powershell
   git clone https://github.com/hkdevs/scoop-forgum
   cd scoop-forgum
   ```

### Step 2: Add Manifest

Create `bucket/forgum.json` with content from `.agent/scoop/bucket/forgum.json`
Update the `hash` field with actual SHA256.

### Step 3: Test

```powershell
scoop bucket add hkdevs https://github.com/hkdevs/scoop-forgum
scoop install hkdevs/forgum
```

### Step 4: Update Bucket

```powershell
git add .
git commit -m "Update forgum to v1.0.3"
git push
```

## Submit to ScoopInstaller/Extras

### Step 1: Fork Extras

1. Fork https://github.com/ScoopInstaller/Extras
2. Clone with sparse checkout:
   ```powershell
   git clone --filter=blob:none --no-checkout https://github.com/YOUR_USERNAME/Extras
   cd Extras
   git sparse-checkout set bucket
   git checkout
   ```

### Step 2: Add Manifest

Copy `forgum.json` to `bucket/`

### Step 3: Submit PR

```powershell
git add bucket/forgum.json
git commit -m "forgum: add version 1.0.3"
git push
```

Create PR to `ScoopInstaller/Extras` master branch.

## Troubleshooting

- Hash mismatch: Recompute SHA256 of release zip
- Version not detected: Update `checkver` section
- Install fails: Ensure PowerShell 5.1+ is available
