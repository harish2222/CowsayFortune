# Forgum — Proof of Legitimacy

This document provides package manager reviewers with evidence that Forgum is a legitimate, well-maintained, and secure open-source project.

## Identity

| Field | Value |
|-------|-------|
| Package Name | Forgum |
| Package Identifier (winget) | `HKDEVS.Forgum` |
| Version | 1.0.3 |
| License | MIT |
| Author | HKDEVS |
| Repository | https://github.com/harish2222/Forgum |
| Issues | https://github.com/harish2222/Forgum/issues |

## Evidence Summary

| Claim | Proof | Link |
|-------|-------|------|
| Open source | MIT License file in repo | [LICENSE](./license.md) |
| Actively maintained | 20+ commits, 2 releases | [Version History](./version-history.md) |
| Tested | 127 tests, 0 failures | [Test Results](./test-results.md) |
| CI passing | 5/5 green runs on all 3 platforms | [CI Status](./ci-status.md) |
| No lint errors | PSScriptAnalyzer 0 issues across 20 files | [Test Results](./test-results.md) |
| Secure | Security harness: injection, path traversal, input validation | [Security Audit](./security-audit.md) |
| Cross-platform | Ubuntu, Windows, macOS tested | [CI Status](./ci-status.md) |
| No malware | Pure PowerShell, no native binaries | See source code |

## Repository Ownership

- **GitHub Account**: https://github.com/harish2222
- **Repository Owner**: harish2222 (HKDEVS)
- **Verified via**: GitHub account linked in manifest Publisher field

## Release Integrity

- **Release URL**: https://github.com/harish2222/Forgum/releases/tag/v1.0.3
- **Asset**: `Forgum-v1.0.3.zip` (317KB)
- **SHA256**: `d9f6623d7dbe1581cbbb1fd58fd748fc0eac5ced576c9fdb0daf31f5f857d262`
- **Signed by**: GitHub Release (immutable once published)
- **Checksum verification**: Manifests include SHA256 hash for integrity check

## Reviewer Checklist

For winget (`microsoft/winget-pkgs`) and Scoop (`ScoopInstaller/Extras`) reviewers:

- [x] MIT License present and correct
- [x] Package URL resolves to valid GitHub repo
- [x] Publisher URL matches repo owner
- [x] Installer URL points to GitHub Release (not third-party)
- [x] SHA256 hash matches release asset
- [x] No bundled executables — pure PowerShell module
- [x] CI badge shows passing status
- [x] Test suite is comprehensive (127 tests)
- [x] No known vulnerabilities (security harness passing)
- [x] Active maintenance (recent commits and releases)
