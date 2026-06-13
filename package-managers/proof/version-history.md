# Version History

## v1.0.3 (2026-06-13) — Current

**Package manager support, interactive setup, figlet banner**

- Added winget manifests (`HKDEVS.Forgum`)
- Added Scoop manifest with autoupdate
- Created `setup.ps1` interactive setup with 6 shell toggles
- Figlet banner across all install scripts
- Fixed double output bug in `Invoke-Forgum -Lolcat`
- Updated README with banner and demo screenshots
- Renamed repo from CowsayFortune to Forgum
- **127 tests passing, 0 lint issues**

Commits: `2cf4ddf` → `d284127`

## v1.0.2 (2026-06-13)

**Lint, security, and code review fixes**

- Fixed lolcat rainbow algorithm (sine-wave color distribution)
- Fixed thought bubble alignment (heredoc regex)
- Added VTTerminal type guard
- Eliminated empty catch blocks
- Added Ghost test suite (30 hostile QA tests)
- Added security harness (22 tests)
- Fixed config defaults

Tag: `9a65494`

## v1.0.1 (2026-06-12)

**Initial public release**

- Core cowsay, fortune, lolcat functionality
- 107 cow templates
- 3 animation modes (static, talking, typewriter)
- Truecolor + 256-color support
- Cross-platform PowerShell module
- CI pipeline (Ubuntu, Windows, macOS)

## Release Assets

| Version | Asset | SHA256 |
|---------|-------|--------|
| v1.0.3 | `Forgum-v1.0.3.zip` (317KB) | `d9f6623d7dbe1581cbbb1fd58fd748fc0eac5ced576c9fdb0daf31f5f857d262` |

## Git Tags

```
v1.0.3 (latest)
v1.0.2
```
