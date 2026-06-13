# Scoop — forgum

## Files

| File | Purpose |
|------|---------|
| `forgum.json` | Scoop manifest with autoupdate |
| `SUBMISSION-GUIDE.md` | Step-by-step PR submission guide |

## Package Identity

- **Name**: `forgum`
- **Version**: 1.0.3
- **Bucket**: `hkdevs` (own) → eventually `Extras` (community)
- **Depends**: `pwsh`

## Quick Submit (Own Bucket)

```powershell
# 1. Create hkdevs/scoop-forgum repo
# 2. Copy forgum.json to bucket/
# 3. Test
scoop bucket add hkdevs https://github.com/hkdevs/scoop-forgum
scoop install hkdevs/forgum
```

## Quick Submit (Extras)

```powershell
# 1. Fork ScoopInstaller/Extras
# 2. Copy forgum.json to bucket/
# 3. Create PR
```

See [SUBMISSION-GUIDE.md](SUBMISSION-GUIDE.md) for full instructions.

## Proof for Reviewers

- License: MIT ([proof](../proof/license.md))
- CI: All green ([status](../proof/ci-status.md))
- Tests: 127/127 passing ([results](../proof/test-results.md))
- Security: No vulnerabilities ([audit](../proof/security-audit.md))
- History: Active maintenance ([versions](../proof/version-history.md))
