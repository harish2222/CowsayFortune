# Package Manager Submission Materials

Everything needed to submit Forgum to winget and Scoop, prove legitimacy to reviewers, and show users we're a real project.

## Structure

```
package-managers/
├── README.md                    ← You are here
│
├── proof/                       ← PROOF OF LEGITIMACY (show to reviewers)
│   ├── README.md                ← Identity + evidence summary + reviewer checklist
│   ├── license.md               ← MIT License (full text)
│   ├── ci-status.md             ← GitHub Actions CI history (5/5 green)
│   ├── test-results.md          ← 127 tests, 0 failures, 3 platforms
│   ├── security-audit.md        ← 22 security tests, threat model
│   └── version-history.md       ← Changelog: v1.0.1 → v1.0.3
│
├── winget/                      ← WINGET SUBMISSION (copy these files)
│   ├── README.md                ← Quick reference for winget
│   ├── HKDEVS.Forgum.yaml       ← Version manifest
│   ├── HKDEVS.Forgum.locale.en-US.yaml  ← Locale + license + tags
│   ├── HKDEVS.Forgum.installer.yaml     ← Installer URL + SHA256
│   └── SUBMISSION-GUIDE.md      ← Fork → PR → merge steps
│
├── scoop/                       ← SCOOP SUBMISSION (copy these files)
│   ├── README.md                ← Quick reference for scoop
│   ├── forgum.json              ← Scoop manifest + autoupdate
│   └── SUBMISSION-GUIDE.md      ← Own bucket + Extras PR steps
│
└── docs/                        ← TECHNICAL DOCUMENTATION
    ├── installer-architecture.md ← 3-stage install design
    ├── winget-submission-guide.md ← Legacy guide (see winget/SUBMISSION-GUIDE.md)
    └── scoop-submission-guide.md  ← Legacy guide (see scoop/SUBMISSION-GUIDE.md)
```

---

## Quick Reference

### For Package Manager Reviewers

**Start here**: [proof/README.md](proof/README.md) — Identity, evidence summary, and reviewer checklist.

| What | Where |
|------|-------|
| License | [proof/license.md](proof/license.md) — MIT |
| CI status | [proof/ci-status.md](proof/ci-status.md) — 5/5 green, 3 platforms |
| Test results | [proof/test-results.md](proof/test-results.md) — 127/127 pass |
| Security | [proof/security-audit.md](proof/security-audit.md) — 22 adversarial tests |
| Version history | [proof/version-history.md](proof/version-history.md) — v1.0.1 → v1.0.3 |

### For Contributors Submitting PRs

| Package Manager | Manifests | Guide | Submit To |
|----------------|-----------|-------|-----------|
| **Winget** | `winget/HKDEVS.Forgum*.yaml` (3 files) | [winget/SUBMISSION-GUIDE.md](winget/SUBMISSION-GUIDE.md) | [microsoft/winget-pkgs](https://github.com/microsoft/winget-pkgs) |
| **Scoop** | `scoop/forgum.json` | [scoop/SUBMISSION-GUIDE.md](scoop/SUBMISSION-GUIDE.md) | [ScoopInstaller/Extras](https://github.com/ScoopInstaller/Extras) |

---

## Release Info

| Field | Value |
|-------|-------|
| Version | 1.0.3 |
| Tag | `v1.0.3` |
| Release URL | https://github.com/harish2222/Forgum/releases/tag/v1.0.3 |
| Asset | `Forgum-v1.0.3.zip` (317KB) |
| SHA256 | `d9f6623d7dbe1581cbbb1fd58fd748fc0eac5ced576c9fdb0daf31f5f857d262` |
| License | MIT |
| CI | [GitHub Actions](https://github.com/harish2222/Forgum/actions/workflows/ci.yml) |

---

## Submission Checklist

### Winget
- [ ] Fork `microsoft/winget-pkgs`
- [ ] Copy 3 YAML files from `winget/` to `manifests/h/HKDEVS/Forgum/1.0.3/`
- [ ] Run `winget validate`
- [ ] Create PR with description template from `winget/SUBMISSION-GUIDE.md`
- [ ] Monitor for `Azure-Pipeline-Passed` → `Validation-Completed`

### Scoop (Own Bucket)
- [ ] Create `hkdevs/scoop-forgum` repo
- [ ] Copy `forgum.json` to `bucket/`
- [ ] Test: `scoop install hkdevs/forgum`
- [ ] Push

### Scoop (Extras)
- [ ] Fork `ScoopInstaller/Extras`
- [ ] Copy `forgum.json` to `bucket/`
- [ ] Create PR with description template from `scoop/SUBMISSION-GUIDE.md`
- [ ] Monitor for review

---

## What Makes Us Legitimate

1. **MIT License** — OSI-approved, permissive, industry standard
2. **127 automated tests** — Unit, integration, adversarial, security
3. **CI on 3 platforms** — Ubuntu, Windows, macOS all green
4. **0 lint issues** — PSScriptAnalyzer at strictest settings
5. **Security harness** — 22 tests against injection, path traversal, tampering
6. **No native binaries** — Pure PowerShell, fully auditable source
7. **GitHub Release** — Immutable asset with SHA256 checksum
8. **Active maintenance** — 20+ commits, 2 releases in development cycle
