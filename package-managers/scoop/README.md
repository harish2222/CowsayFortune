# Scoop — forgum

## Files

| File | Purpose |
|------|---------|
| `forgum.json` | Scoop manifest with autoupdate |
| `SUBMISSION-GUIDE.md` | Step-by-step PR submission guide |

## Package Identity

- **Name**: `forgum`
- **Version**: 1.0.3
- **Bucket**: `hkdevloops` (own) → eventually `Extras` (community)
- **Depends**: `pwsh`

## Quick Submit (Own Bucket)

```powershell
# 1. Create hkdevloops/forgum repo
# 2. Copy forgum.json to bucket/
# 3. Test
scoop bucket add hkdevloops https://github.com/hkdevloops/forgum
scoop install hkdevloops/forgum
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
