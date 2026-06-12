# Changelog

All notable changes to Forgum will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-12

### Added

- **Profile Customization Functions**
  - `cowconfig` - Quick config access with dot notation
  - `cowpreview` - Preview cows with custom text
  - `cowgallery` - Browse random cows
  - `lolcat-toggle` - Toggle rainbow colors
  - `cow-animate` - Switch animation modes
  - `cow-eyes` - Set cow eyes with presets

- **Documentation**
  - Comprehensive customization guide in README
  - Advanced contributor customization methods
  - Custom cow file creation guide
  - Animation mode extension guide
  - Shell wrapper examples
  - Tab completion setup
  - VS Code integration examples

### Changed

- Updated README with ghost-writing style
- Enhanced CONTRIBUTING.md with customization methods
- Improved profile integration with tab completion

## [1.0.0] - 2026-06-12

### Added

- **Core Features**
  - `Invoke-Cowsay` - Display ASCII cow with custom message
  - `Invoke-Forgum` - Combine cowsay + fortune + optional lolcat
  - `Get-Fortune` - Get random fortune from database
  - `Get-CFCow` - List available cows or read specific cow
  - `Get-CFConfig` / `Set-CFConfig` - Configuration management
  - `Show-CFAnimation` - Animated display modes

- **Cow Collection**
  - 190 cow files ported from piuccio/cowsay
  - Support for custom cow files
  - Cow mode presets (borg, dead, greedy, paranoia, stoned, tired, wasted, youthful)
  - Random cow selection

- **Fortune System**
  - Fortune database with thousands of quotes
  - Support for custom fortune databases
  - Cached parsing for performance

- **Lolcat Rainbow**
  - Truecolor (24-bit) support
  - 256-color fallback
  - Configurable frequency and spread
  - ANSI escape passthrough

- **Animation Modes**
  - Static (instant display)
  - Typewriter (character-by-character)
  - Talking (mouth movement simulation)

- **Multi-Shell Integration**
  - Bash wrapper (`Forgum.sh`)
  - Zsh wrapper with completions (`Forgum.zsh`)
  - Fish wrapper (`Forgum.fish`)
  - PowerShell native support

- **tmux/rmux Integration**
  - Status bar fortune display
  - Configurable pane and refresh

- **Configuration**
  - JSON-based config file
  - Platform-appropriate locations
  - Environment variable override (`Forgum_CONFIG`)
  - Atomic file writes (prevents corruption)
  - Config caching with TTL

- **Installation**
  - Fun PowerShell installer with ASCII art
  - Fun bash/zsh/fish installer
  - Automatic dependency checking
  - Shell profile integration
  - One-liner install commands

- **Testing**
  - 66 Pester tests
  - Module loading tests
  - Config system tests
  - Fortune system tests
  - Cow system tests
  - Lolcat colorization tests
  - Animation system tests
  - Security tests
  - Edge case tests

- **Documentation**
  - Comprehensive README
  - API documentation
  - Contributing guidelines
  - Changelog
  - License (MIT)

### Performance

- Cow file caching (avoids repeated disk reads)
- Fortune database caching
- Config caching with 30-second TTL
- `StringBuilder`-based string operations (O(n) vs O(n²))
- `List[T]` instead of array concatenation

### Security

- No `Invoke-Expression` on user input
- Input validation on all parameters
- Atomic config file writes
- Proper error handling with try/catch
