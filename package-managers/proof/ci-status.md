# CI Status

## GitHub Actions

**Workflow**: `.github/workflows/ci.yml`
**Status**: All runs passing

### Recent Runs (as of 2026-06-13)

| Run | Branch | Status | Platforms |
|-----|--------|--------|-----------|
| #5 | main | **PASS** | Ubuntu, Windows, macOS |
| #4 | main | **PASS** | Ubuntu, Windows, macOS |
| #3 | v1.0.3 | **PASS** | Ubuntu, Windows, macOS |
| #2 | main | **PASS** | Ubuntu, Windows, macOS |
| #1 | main | **PASS** | Ubuntu, Windows, macOS |

**5/5 consecutive green runs on main branch.**

### CI Jobs

| Job | Description | Status |
|-----|-------------|--------|
| Lint | PSScriptAnalyzer at Error+Warning severity | PASS |
| Validate Module | Module manifest + data file verification | PASS |
| Test (ubuntu-latest) | Pester test suite on Ubuntu | PASS |
| Test (windows-latest) | Pester test suite on Windows | PASS |
| Test (macos-latest) | Pester test suite on macOS | PASS |
| Build Package | Create release zip artifact | PASS |
| Release | Publish GitHub Release with asset | PASS |

### CI Configuration

- **Excluded lint rules**: `PSReviewUnusedParameter`, `PSAvoidUsingWriteHost`, `PSUseSingularNouns`, `PSUseBOMForUnicodeEncodedFile`
- **Test framework**: Pester 5
- **PowerShell versions tested**: 5.1 (Windows), 7.x (all platforms)

### Badge

```
![CI](https://github.com/harish2222/Forgum/actions/workflows/ci.yml/badge.svg)
```

**Live badge URL**: https://github.com/harish2222/Forgum/actions/workflows/ci.yml
