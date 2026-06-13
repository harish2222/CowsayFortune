# Winget — HKDEVS.Forgum

## Files

| File | Purpose |
|------|---------|
| `HKDEVS.Forgum.yaml` | Version manifest |
| `HKDEVS.Forgum.locale.en-US.yaml` | Locale, description, license, tags |
| `HKDEVS.Forgum.installer.yaml` | Installer type, URL, SHA256, switches |
| `SUBMISSION-GUIDE.md` | Step-by-step PR submission guide |

## Package Identity

- **Identifier**: `HKDEVS.Forgum`
- **Version**: 1.0.3
- **Installer**: zip (PowerShell module)
- **Scope**: user

## Quick Submit

```powershell
# 1. Fork microsoft/winget-pkgs
# 2. Copy these 3 YAML files to manifests/h/HKDEVS/Forgum/1.0.3/
# 3. Validate
winget validate manifests\h\HKDEVS\Forgum\1.0.3\
# 4. Commit and create PR
```

See [SUBMISSION-GUIDE.md](SUBMISSION-GUIDE.md) for full instructions.

## Proof for Reviewers

- License: MIT ([proof](../proof/license.md))
- CI: All green ([status](../proof/ci-status.md))
- Tests: 127/127 passing ([results](../proof/test-results.md))
- Security: No vulnerabilities ([audit](../proof/security-audit.md))
- History: Active maintenance ([versions](../proof/version-history.md))
