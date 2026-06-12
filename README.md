# CowsayFortune

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/powershell-5.1%2B-blue.svg" alt="PowerShell">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
  <img src="https://img.shields.io/badge/tests-66%20passing-brightgreen.svg" alt="Tests">
  <img src="https://img.shields.io/badge/cows-190-orange.svg" alt="Cows">
</p>

<p align="center">
  <b>The fun way to get your daily fortune!</b><br>
  Cross-platform PowerShell module combining <a href="https://github.com/piuccio/cowsay">cowsay</a>, <a href="https://en.wikipedia.org/wiki/Fortune_(Unix)">fortune</a>, and <a href="https://github.com/busyloop/lolcat">lolcat</a> with rainbow colorization, animations, and multi-shell integration.
</p>

---

## Quick Install

**One-liner install (PowerShell):**

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/HKDEVS/CowsayFortune/main/install.ps1'))
```

**One-liner install (Bash/Zsh):**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/HKDEVS/CowsayFortune/main/install.sh)
```

**Manual install:**

```powershell
git clone https://github.com/HKDEVS/CowsayFortune.git
Import-Module ./CowsayFortune/CowsayFortune.psd1
```

---

## Features

- **190 cow files** - From the original piuccio/cowsay collection
- **Fortune database** - Thousands of classic quotes
- **Lolcat rainbow** - Truecolor (24-bit) and 256-color support
- **3 animation modes** - Static, talking, typewriter
- **Multi-shell** - Bash, Zsh, Fish, PowerShell
- **tmux/rmux** - Status bar fortune display
- **Cross-platform** - Windows, macOS, Linux
- **Configurable** - JSON config with sensible defaults
- **Fast** - Cached file reads, optimized string operations
- **Secure** - No code execution, input validation, atomic writes

## Quick Start

```powershell
# Show a cow with a random fortune
Invoke-CowsayFortune

# Show a cow with your own text
Invoke-Cowsay -Text "Hello, World!"

# Get a random fortune
Get-Fortune

# List all 190 available cows
Get-CFCow

# Use a specific cow
Invoke-Cowsay -Text "Tux says hi" -CowFile 'tux'

# Enable rainbow colors
Set-CFConfig -Config @{ lolcat = @{ enabled = $true } }
Invoke-CowsayFortune

# Try different cow modes
Set-CFConfig -Config @{ cow = @{ mode = 'p' } }  # Paranoia eyes
Invoke-Cowsay -Text "They're watching..."
```

## API Reference

### `Invoke-Cowsay`

Display a cow with a message.

```powershell
Invoke-Cowsay -Text "Hello" [-CowFile <name>] [-Eyes <chars>] [-Tongue <chars>] [-Thoughts <char>]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `Text` | `''` | Message to display |
| `CowFile` | `'default'` | Cow file name (without .cow) |
| `Eyes` | `'oo'` | Two-character eye string |
| `Tongue` | `'  '` | Two-character tongue string |
| `Thoughts` | `'\'` | Thought bubble character |

### `Invoke-CowsayFortune`

Combine cowsay + fortune + optional lolcat.

```powershell
Invoke-CowsayFortune [-Think] [-CowFile <name>] [-Eyes <chars>] [-Tongue <chars>]
```

### `Get-Fortune`

Get a random fortune from the database.

```powershell
Get-Fortune [-Database <name>]
```

### `Get-CFCow`

List available cows or read a specific cow file.

```powershell
Get-CFCow [-Name <cowname>]
```

### `Get-CFConfig` / `Set-CFConfig`

Read or write the configuration.

```powershell
$config = Get-CFConfig
$config.lolcat.enabled = $true
Set-CFConfig -Config $config
```

### `Show-CFAnimation`

Display cow output with animation.

```powershell
Show-CFAnimation -CowOutput <string> [-Message <string>]
```

## Configuration

Config file locations:
- **Windows**: `~/Documents/PowerShell/cowsayfortune/config.json`
- **Linux/Mac**: `~/.config/cowsayfortune/config.json`
- **Override**: Set `$env:COWSAYFORTUNE_CONFIG`

### Default Config

```json
{
  "animation": { "mode": "static", "speed": 20, "duration": 12, "spread": 3.0 },
  "cow": { "file": "default", "random": false, "mode": null, "eyes": "oo", "tongue": "  " },
  "fortune": { "database": "fortunes", "offensive": false },
  "lolcat": { "enabled": false, "truecolor": true, "frequency": 0.1 },
  "output": { "wordWrap": true, "maxWidth": 60 },
  "shell": { "integration": "auto", "tmux": { "enabled": false, "pane": "status-right" } }
}
```

### Cow Modes

| Mode | Eyes | Description |
|------|------|-------------|
| `b` | `==` | Borg |
| `d` | `xx` | Dead |
| `g` | `$$` | Greedy |
| `p` | `@@` | Paranoia |
| `s` | `**` | Stoned |
| `t` | `--` | Tired |
| `w` | `OO` | Wasted |
| `y` | `..` | Youthful |

### Animation Modes

| Mode | Description |
|------|-------------|
| `static` | Instant display (default) |
| `talking` | Simulates mouth movement |
| `typewriter` | Types character by character |

### Lolcat Options

| Option | Default | Description |
|--------|---------|-------------|
| `enabled` | `false` | Enable rainbow colors |
| `truecolor` | `true` | Use 24-bit color (falls back to 256) |
| `frequency` | `0.1` | Rainbow frequency (higher = tighter) |
| `invert` | `false` | Invert colors |

## Shell Integration

### Bash/Zsh/Fish

Add to your shell config:

```bash
# Bash (~/.bashrc)
source /path/to/CowsayFortune/Scripts/cowsayfortune.sh

# Zsh (~/.zshrc)
source /path/to/CowsayFortune/Scripts/cowsayfortune.zsh

# Fish (~/.config/fish/config.fish)
source /path/to/CowsayFortune/Scripts/cowsayfortune.fish
```

### tmux Integration

Add to `~/.tmux.conf`:

```
set -g status-right "#(bash /path/to/Scripts/tmux-cowsayfortune.sh)"
set -g status-interval 300
```

### PowerShell Profile

Add to `$PROFILE`:

```powershell
Import-Module CowsayFortune
Invoke-CowsayFortune  # Show fortune on shell start
```

## Testing

```powershell
# Run all 66 tests
Import-Module Pester
Invoke-Pester -Path ./Tests/CowsayFortune.Tests.ps1

# Run with verbose output
Invoke-Pester -Path ./Tests/CowsayFortune.Tests.ps1 -Verbose
```

### Test Coverage

- Module loading and exports
- Configuration system (defaults, persistence, validation)
- Fortune system (reading, caching, errors)
- Cow system (listing, reading, rendering, all 190 cows)
- Lolcat colorization (enabled/disabled)
- Animation system (static mode)
- Security (no code execution, input handling)
- Edge cases (empty input, unicode, long messages)

## Project Structure

```
CowsayFortune/
├── CowsayFortune.psd1          # Module manifest
├── CowsayFortune.psm1          # Entry point with caching
├── Public/                      # 7 exported functions
├── Private/                     # Internal functions + cache
│   ├── Animation/               # Static, Talking, Typewriter
│   └── Security/                # (reserved)
├── Data/
│   ├── Cows/                    # 190 .cow files
│   ├── Fortunes/                # Fortune database
│   └── Templates/               # Default config
├── Scripts/                     # Shell wrappers
├── Tests/                       # 66 Pester tests
├── install.ps1                  # Fun PowerShell installer
├── install.sh                   # Fun bash installer
├── uninstall.ps1                # Uninstaller
├── CONTRIBUTING.md              # Contribution guide
├── CHANGELOG.md                 # Version history
├── LICENSE                      # MIT License
└── README.md                    # This file
```

## Performance

- **Cow file caching** - Parsed once, reused across calls
- **Fortune caching** - Database parsed once per session
- **Config caching** - 30-second TTL avoids disk reads
- **StringBuilder** - O(n) string operations instead of O(n²)
- **List[T]** - Pre-allocated lists instead of array concatenation

## Security

- Cow files are read as templates, never executed
- All user input is validated and escaped
- Config files use atomic writes (no corruption on crash)
- No `Invoke-Expression` anywhere in the codebase
- No external dependencies required

## Requirements

- PowerShell 5.1+ (Windows) or PowerShell 7+ (cross-platform)
- No external dependencies

## Uninstall

```powershell
# PowerShell
.\uninstall.ps1

# Or manually remove:
# 1. Module: ~/Documents/PowerShell/Modules/CowsayFortune/
# 2. Config: ~/Documents/PowerShell/cowsayfortune/
# 3. Profile entry in $PROFILE
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Credits

- [piuccio/cowsay](https://github.com/piuccio/cowsay) - Original cow files
- [fortune-mod](https://github.com/shlomif/fortune-mod) - Fortune database
- [lolcat](https://github.com/busyloop/lolcat) - Rainbow colorization algorithm
