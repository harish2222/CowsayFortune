# Package Manager Submission Materials

All manifests and documentation for submitting Forgum to winget and Scoop.

## Contents

```
package-managers/
├── README.md                              # This file
├── winget/                                # Winget manifests (ready to submit)
│   ├── HKDEVS.Forgum.yaml                 # Version manifest
│   ├── HKDEVS.Forgum.locale.en-US.yaml    # Locale/metadata manifest
│   └── HKDEVS.Forgum.installer.yaml       # Installer manifest (zip + SHA256)
├── scoop/                                 # Scoop manifest (ready to submit)
│   └── forgum.json                        # Scoop package manifest
└── docs/                                  # Submission guides
    ├── winget-submission-guide.md          # Step-by-step winget PR guide
    ├── scoop-submission-guide.md           # Step-by-step scoop PR guide
    └── installer-architecture.md           # Technical design documentation
```

## Quick Reference

| Package Manager | Manifest Path | Submit To |
|----------------|---------------|-----------|
| Winget | `winget/HKDEVS.Forgum*.yaml` | [microsoft/winget-pkgs](https://github.com/microsoft/winget-pkgs) |
| Scoop | `scoop/forgum.json` | [hkdevs/scoop-forgum](https://github.com/hkdevs/scoop-forgum) then [ScoopInstaller/Extras](https://github.com/ScoopInstaller/Extras) |

## Release Info

- **Version**: 1.0.3
- **Release URL**: https://github.com/harish2222/Forgum/releases/tag/v1.0.3
- **Asset**: `Forgum-v1.0.3.zip` (317KB)
- **SHA256**: `d9f6623d7dbe1581cbbb1fd58fd748fc0eac5ced576c9fdb0daf31f5f857d262`

## Submission Steps

### Winget
1. Fork `microsoft/winget-pkgs`
2. Copy 3 YAML files from `winget/` to `manifests/h/HKDEVS/Forgum/1.0.3/`
3. Create PR — see `docs/winget-submission-guide.md`

### Scoop
1. Create `hkdevs/scoop-forgum` repo
2. Copy `scoop/forgum.json` to `bucket/`
3. Test: `scoop install hkdevs/forgum`
4. Later submit to `ScoopInstaller/Extras` — see `docs/scoop-submission-guide.md`
