<p align="center">
  <img src="assets/logo.png" alt="Forgum" width="400">
</p>

<h1 align="center">Forgum</h1>

<p align="center">
  <b>fortune + cow + rainbow = joy</b>
</p>

<p align="center">
  <a href="https://github.com/harish2222/CowsayFortune/releases"><img src="https://img.shields.io/badge/version-1.0.0-blue?style=for-the-badge" alt="Version"></a>
  <a href="https://github.com/harish2222/CowsayFortune"><img src="https://img.shields.io/badge/powershell-5.1+-blueviolet?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell"></a>
  <a href="https://github.com/harish2222/CowsayFortune/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License"></a>
  <a href="https://github.com/harish2222/CowsayFortune/actions"><img src="https://img.shields.io/badge/tests-67%20passing-brightgreen?style=for-the-badge" alt="Tests"></a>
  <a href="#-cows"><img src="https://img.shields.io/badge/cows-107-orange?style=for-the-badge" alt="Cows"></a>
  <a href="#-rainbow"><img src="https://img.shields.io/badge/rainbow-lolcat-pink?style=for-the-badge" alt="Lolcat"></a>
</p>

<p align="center">
  A cross-platform PowerShell module that combines <b>cowsay</b>, <b>fortune</b>, and <b>lolcat</b> into one beautiful, configurable, and fun terminal experience.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Windows-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
</p>

---

## Demo

```
  ╭─────────────────────────────────────────────────────────╮
  │ The best way to predict the future is to invent it.    │
  │                                        -- Alan Kay     │
  ╰─────────────────────────────────────────────────────────╯
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||
```

<table>
<tr>
<td>

**Static mode**

```
  ╭─────────────────────────────────╮
  │ A journey of a thousand miles  │
  │ begins with a single step.     │
  ╰─────────────────────────────────╯
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
```

</td>
<td>

**With rainbow lolcat**

```
  ╭─────────────────────────────────╮
  │ Code is like humor. When you    │
  │ have to explain it, it's bad.   │
  ╰─────────────────────────────────╯
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
```

*(imagine this in rainbow colors)*

</td>
</tr>
</table>

---

## Install

### One-liner (PowerShell)

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/CowsayFortune/main/install.ps1'))
```

### One-liner (Bash/Zsh/Fish)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harish2222/CowsayFortune/main/install.sh)
```

### Manual

```powershell
git clone https://github.com/harish2222/CowsayFortune.git
Import-Module ./CowsayFortune/CowsayFortune.psd1
```

---

## Features

<table>
<tr>
<td width="50%">

### 🐄 107 Animal Cows
Curated collection of beautifully drawn animal ASCII art. From tux to dragon, cat to whale.

### 🌈 Lolcat Rainbow
Truecolor (24-bit) and 256-color support with configurable frequency and invert options.

### ✨ 3 Animation Modes
- **Static** — instant display
- **Talking** — mouth movement simulation
- **Typewriter** — character-by-character reveal

</td>
<td width="50%">

### 🚀 Fast
Module-level caching with TTL, optimized string operations, and zero cold-start penalty.

### 🔒 Secure
No `Invoke-Expression`, input validation, path traversal guards, and atomic config writes.

### 🌍 Cross-Platform
Native PowerShell — Windows, macOS, Linux. Multi-shell integration for Bash, Zsh, Fish, tmux.

</td>
</tr>
</table>

---

## Quick Start

```powershell
# Fortune + cow combo
Invoke-CowsayFortune

# Your own message
Invoke-Cowsay -Text "Hello, World!"

# Pick a specific cow
Invoke-Cowsay -Text "Tux says hi" -CowFile 'tux'

# Random fortune
Get-Fortune

# List all 107 cows
Get-CFCow
```

### Rainbow Mode

```powershell
# Enable rainbow
Set-CFConfig -Config @{ lolcat = @{ enabled = $true } }
Invoke-CowsayFortune

# Truecolor vs 256-color
Set-CFConfig -Config @{ lolcat = @{ enabled = $true; truecolor = $true } }  # 24-bit
Set-CFConfig -Config @{ lolcat = @{ enabled = $true; truecolor = $false } } # 256
```

### Cow Moods

```powershell
# Set mood via config
Set-CFConfig -Config @{ cow = @{ mode = 'p' } }  # Paranoia eyes (@@)
Set-CFConfig -Config @{ cow = @{ mode = 'd' } }  # Dead eyes (xx)
Set-CFConfig -Config @{ cow = @{ mode = 'g' } }  # Greedy eyes ($$)

# Or pass eyes directly
Invoke-Cowsay -Text "Party time!" -Eyes '**'
```

---

## API Reference

### `Invoke-Cowsay`

```powershell
Invoke-Cowsay -Text "Hello" [-CowFile <name>] [-Eyes <chars>] [-Tongue <chars>] [-Thoughts <char>]
```

| Parameter | Default | Description |
|:----------|:--------|:------------|
| `Text` | `''` | Message to display |
| `CowFile` | `'default'` | Cow file name (without `.cow`) |
| `Eyes` | `'oo'` | Two-character eye string |
| `Tongue` | `'  '` | Two-character tongue string |
| `Thoughts` | `'\'` | Thought bubble character |

### `Invoke-CowsayFortune`

```powershell
Invoke-CowsayFortune [-Think] [-CowFile <name>] [-Eyes <chars>] [-Tongue <chars>]
```

### `Get-Fortune`

```powershell
Get-Fortune [-Database <name>]
```

### `Get-CFCow`

```powershell
Get-CFCow [-Name <cowname>]
```

### `Get-CFConfig` / `Set-CFConfig`

```powershell
$config = Get-CFConfig
$config.lolcat.enabled = $true
Set-CFConfig -Config $config
```

### `Show-CFAnimation`

```powershell
Show-CFAnimation -CowOutput <string> [-Message <string>]
```

---

## Configuration

| Platform | Path |
|:---------|:-----|
| Windows | `~/Documents/PowerShell/cowsayfortune/config.json` |
| Linux/Mac | `~/.config/cowsayfortune/config.json` |
| Override | `$env:COWSAYFORTUNE_CONFIG` |

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

### Cow Moods

| Mode | Eyes | Description |
|:-----|:-----|:------------|
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
|:-----|:------------|
| `static` | Instant display (default) |
| `talking` | Simulates mouth movement |
| `typewriter` | Types character by character |

---

## Shell Integration

### Bash / Zsh / Fish

```bash
# Add to ~/.bashrc or ~/.zshrc
fortune | cowsay -f $( cowsay -l | shuf -n1 )

# Or use PowerShell module from bash
pwsh -Command "Import-Module CowsayFortune; Invoke-CowsayFortune"
```

### tmux Status Bar

```bash
# Add to ~/.tmux.conf
set -g status-right "#(pwsh -Command 'Import-Module CowsayFortune; Get-Fortune' 2>/dev/null)"
set -g status-interval 300
```

### PowerShell Profile

```powershell
# Add to $PROFILE
Import-Module CowsayFortune
Invoke-CowsayFortune  # Show fortune on shell start
```

---

## Customization

### Quick Config Functions

Add these to your `$PROFILE`:

```powershell
# Quick config toggle
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

# Preview any cow
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

# Toggle rainbow
function lolcat-toggle {
  $config = Get-CFConfig
  $config.lolcat.enabled = -not $config.lolcat.enabled
  Set-CFConfig -Config $config
  Write-Host "Lolcat: $(if ($config.lolcat.enabled) {'ON'} else {'OFF'})"
}

# Set animation
function cow-animate {
  param([ValidateSet('static','talking','typewriter')]$Mode)
  $config = Get-CFConfig
  $config.animation.mode = $Mode
  Set-CFConfig -Config $config
  Write-Host "Animation: $Mode"
}

# Set cow eyes
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

Create a `.cow` file in `Data/Cows/`:

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

### Custom Fortunes

Add your own to `~/Documents/PowerShell/fortunes.txt`:

```
Your first fortune here
%
Your second fortune here
%
Your third fortune here
```

---

## Requirements

- **PowerShell 5.1+** (Windows) or **PowerShell 7+** (cross-platform)
- **No external dependencies**

---

## Uninstall

```powershell
.\uninstall.ps1
```

Or manually:
1. Module: `~/Documents/PowerShell/Modules/CowsayFortune/`
2. Config: `~/Documents/PowerShell/cowsayfortune/`
3. Profile entry in `$PROFILE`

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Credits

| Project | Description |
|:--------|:------------|
| [piuccio/cowsay](https://github.com/piuccio/cowsay) | Original cow files |
| [fortune-mod](https://github.com/shlomif/fortune-mod) | Fortune database |
| [lolcat](https://github.com/busyloop/lolcat) | Rainbow colorization algorithm |

---

<p align="center">
  Made with ❤️ and a cow
</p>
