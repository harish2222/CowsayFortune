# CowsayFortune

<p align="center">
  <a href="https://github.com/harish2222/CowsayFortune/releases"><img src="https://img.shields.io/badge/version-1.0.0-blue.svg" alt="Version"></a>
  <a href="https://github.com/harish2222/CowsayFortune"><img src="https://img.shields.io/badge/powershell-5.1%2B-blue.svg" alt="PowerShell"></a>
  <a href="https://github.com/harish2222/CowsayFortune/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"></a>
  <a href="https://github.com/harish2222/CowsayFortune/actions"><img src="https://img.shields.io/badge/tests-66%20passing-brightgreen.svg" alt="Tests"></a>
  <a href="https://github.com/harish2222/CowsayFortune"><img src="https://img.shields.io/badge/cows-107-orange.svg" alt="Cows"></a>
</p>

<p align="center">
  <b>The fun way to get your daily fortune!</b><br>
  Cross-platform PowerShell module combining <a href="https://github.com/piuccio/cowsay">cowsay</a>, <a href="https://en.wikipedia.org/wiki/Fortune_(Unix)">fortune</a>, and <a href="https://github.com/busyloop/lolcat">lolcat</a> with rainbow colorization, animations, and multi-shell integration.
</p>

---

## Quick Install

**One-liner install (PowerShell):**

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/CowsayFortune/main/install.ps1'))
```

**One-liner install (Bash/Zsh):**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harish2222/CowsayFortune/main/install.sh)
```

**Manual install:**

```powershell
git clone https://github.com/harish2222/CowsayFortune.git
Import-Module ./CowsayFortune/CowsayFortune.psd1
```

---

## Features

- **107 animal cow files** - Curated animal-only collection from piuccio/cowsay
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

# List all 107 available cows
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
# Bash (~/.bashrc) - add after importing CowsayFortune
fortune | cowsay -f $( cowsay -l | shuf -n1 )

# Or use the PowerShell module directly from bash
pwsh -Command "Import-Module CowsayFortune; Invoke-CowsayFortune"
```

### tmux Integration

Add to `~/.tmux.conf`:

```
set -g status-right "#(pwsh -Command 'Import-Module CowsayFortune; Get-Fortune' 2>/dev/null)"
set -g status-interval 300
```

### PowerShell Profile

Add to `$PROFILE`:

```powershell
Import-Module CowsayFortune
Invoke-CowsayFortune  # Show fortune on shell start
```

## Customization

### Quick Config Functions

Add these to your `$PROFILE` for quick access:

```powershell
# Quick config access
function cowconfig {
  param([string]$Path, [object]$Value)
  $config = Get-CFConfig
  if ($Path) {
    $parts = $Path -split '\.'
    $current = $config
    foreach ($part in $parts[0..($parts.Length-2)]) { $current = $current.$part }
    if ($Value) { $current.$parts[-1] = $Value; Set-CFConfig -Config $config }
    else { $current.$parts[-1] }
  } else { $config | ConvertTo-Json -Depth 4 }
}

# Quick cow preview
function cowpreview {
  param([string]$Cow = 'default', [string]$Text = 'Hello!')
  Invoke-Cowsay -Text $Text -CowFile $Cow
}

# Random cow gallery
function cowgallery {
  param([int]$Count = 5)
  Get-CFCow | Get-Random -Count $Count | ForEach-Object {
    Invoke-Cowsay -Text (Get-Fortune) -CowFile $_.Name
  }
}

# Toggle lolcat
function lolcat-toggle {
  $config = Get-CFConfig
  $config.lolcat.enabled = -not $config.lolcat.enabled
  Set-CFConfig -Config $config
  Write-Host "Lolcat: $(if ($config.lolcat.enabled) {'ON'} else {'OFF'})"
}

# Set animation mode
function cow-animate {
  param([ValidateSet('static','talking','typewriter')]$Mode)
  $config = Get-CFConfig
  $config.animation.mode = $Mode
  Set-CFConfig -Config $config
  Write-Host "Animation: $Mode"
}

# Cow eyes preset
function cow-eyes {
  param(
    [ValidateSet('borg','dead','greedy','paranoia','stoned','tired','wasted','youthful')]$Preset,
    [string]$Custom
  )
  $eyes = switch ($Preset) {
    'borg' {'=='}, 'dead' {'xx'}, 'greedy' {'$$'}, 'paranoia' {'@@'},
    'stoned' {'**'}, 'tired' {'--'}, 'wasted' {'OO'}, 'youthful' {'..'}
    default { $Custom }
  }
  $config = Get-CFConfig
  $config.cow.eyes = $eyes
  Set-CFConfig -Config $config
  Write-Host "Cow eyes: $eyes"
}
```

### Custom Cow Files

Create your own `.cow` file in `Data/Cows/`:

```perl
$the_cow = <<EOC;
        \\   ^__^
         \\  (oo)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||
EOC
```

Use `$eyes`, `$tongue`, `$thoughts` for customizable parts.

### Custom Fortune Database

Add your own fortunes to `~/Documents/PowerShell/fortunes.txt`:

```
Your first fortune here
%
Your second fortune here
%
Your third fortune here
```

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
