# Package Manager Distribution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Forgum to winget and Scoop, create interactive setup script with shell toggles, and document the submission process.

**Architecture:** New `setup.ps1` handles interactive/silent shell configuration. Winget manifest wraps `install.ps1 -Silent`. Scoop manifest downloads zip and runs setup. All scripts share a figlet-style FORGUM banner.

**Tech Stack:** PowerShell 5.1+, YAML manifests, GitHub Actions

---

## Figlet Banner

All scripts use this banner:

```
  _____ _____ ___ _____ ___ ___  _  ___
 /  ___|  ___/ _ \_   _|_ _/ _ \| |/ /
 \ `--. | |_ / /_\ \| |  | | | | ' / 
  `--. \|  _||  _  || |  | | | | . \ 
 /\__/ /| |  | | | || | _| |_| | |\ \
 \____/ \_|  \_| |_/\_/ |___/ \_| |_/
```

---

## File Map

| Action | File | Purpose |
|--------|------|---------|
| Create | `setup.ps1` | Interactive/silent shell configuration |
| Create | `.agent/winget/manifests/h/HKDEVS/Forgum/1.0.3/HKDEVS.Forgum.yaml` | Winget version manifest |
| Create | `.agent/winget/manifests/h/HKDEVS/Forgum/1.0.3/HKDEVS.Forgum.locale.en-US.yaml` | Winget locale manifest |
| Create | `.agent/winget/manifests/h/HKDEVS/Forgum/1.0.3/HKDEVS.Forgum.installer.yaml` | Winget installer manifest |
| Create | `.agent/scoop/bucket/forgum.json` | Scoop manifest |
| Create | `.agent/winget-submission-guide.md` | Winget submission steps |
| Create | `.agent/scoop-submission-guide.md` | Scoop submission steps |
| Create | `.agent/installer-architecture.md` | Technical design doc |
| Modify | `install.ps1` | Add `-Silent` flag, update banner |
| Modify | `install.sh` | Update banner to figlet style |
| Modify | `Forgum.psd1` | Bump version to 1.0.3, update ReleaseNotes |
| Modify | `README.md` | Add winget/scoop install instructions |

---

## Task 1: Create `setup.ps1` — Interactive Setup Script

**Files:**
- Create: `setup.ps1`

- [ ] **Step 1: Create setup.ps1 with figlet banner and parameters**

```powershell
<#
.SYNOPSIS
    Forgum Shell Setup - Configure terminal integration interactively.
.DESCRIPTION
    Configures Fortune cow on startup, lolcat, cow file, animation, aliases, and tab completion.
    Supports -NonInteractive for package managers (winget/scoop).
.PARAMETER NonInteractive
    Skip all prompts, use defaults (fortune=yes, lolcat=yes, cow=default, animation=static, aliases=yes, completion=yes).
.PARAMETER Force
    Overwrite existing config without asking.
.PARAMETER NoProfile
    Don't modify PowerShell profile.
.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -NonInteractive -Force
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param(
    [switch]$NonInteractive,
    [switch]$Force,
    [switch]$NoProfile
)

#Requires -Version 5.1

$FigletBanner = @"
  _____ _____ ___ _____ ___ ___  _  ___
 /  ___|  ___/ _ \_   _|_ _/ _ \| |/ /
 \ `--. | |_ / /_\ \| |  | | | | ' / 
  `--. \|  _||  _  || |  | | | | . \ 
 /\__/ /| |  | | | || | _| |_| | |\ \
 \____/ \_|  \_| |_/\_/ |___/ \_| |_/
"@

function Show-Banner {
    Write-Host ""
    Write-Host $FigletBanner -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Shell Setup Wizard" -ForegroundColor Magenta
    Write-Host ""
}

function Show-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "  ── $Title ──" -ForegroundColor Yellow
    Write-Host ""
}

function Get-UserChoice {
    param(
        [string]$Prompt,
        [bool]$Default
    )
    $defaultStr = if ($Default) { "Y/n" } else { "y/N" }
    Write-Host "  $Prompt " -NoNewline -ForegroundColor White
    Write-Host "[$defaultStr]: " -NoNewline -ForegroundColor DarkGray
    
    if ($NonInteractive) {
        Write-Host $(if ($Default) { "yes" } else { "no" }) -ForegroundColor Green
        return $Default
    }
    
    $response = Read-Host
    if ([string]::IsNullOrWhiteSpace($response)) { return $Default }
    return $response -match '^[yY]'
}

function Get-UserSelection {
    param(
        [string]$Prompt,
        [string[]]$Options,
        [string]$Default
    )
    Write-Host "  $Prompt" -ForegroundColor White
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($Options[$i] -eq $Default) { " *" } else { "  " }
        Write-Host "    $($i + 1)$marker $($Options[$i])" -ForegroundColor Cyan
    }
    
    if ($NonInteractive) {
        $defaultIdx = [Array]::IndexOf($Options, $Default) + 1
        Write-Host "  Selection [$defaultIdx]: $Default" -ForegroundColor Green
        return $Default
    }
    
    $idx = Read-Host "  Selection [1-$($Options.Count)]"
    if ([string]::IsNullOrWhiteSpace($idx)) { return $Default }
    $num = 0
    if ([int]::TryParse($idx, [ref]$num) -and $num -ge 1 -and $num -le $Options.Count) {
        return $Options[$num - 1]
    }
    return $Default
}

# ── Main ──
Show-Banner

# Check if Forgum is installed
$forgumPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum\Forgum.psd1"
if (-not (Test-Path $forgumPath)) {
    # Try module path
    $forgumPath = Join-Path $PSScriptRoot "Forgum.psd1"
    if (-not (Test-Path $forgumPath)) {
        Write-Host "  ERROR: Forgum module not found." -ForegroundColor Red
        Write-Host "  Run install.ps1 first, then run this script." -ForegroundColor Yellow
        exit 1
    }
}

try {
    Import-Module $forgumPath -Force -ErrorAction Stop
} catch {
    Write-Host "  ERROR: Failed to load Forgum module: $_" -ForegroundColor Red
    exit 1
}

$config = Get-CFConfig
Write-Host "  Forgum module loaded successfully!" -ForegroundColor Green

# ── Toggle 1: Fortune Cow on Startup ──
Show-Section "Fortune Cow on Startup"
$fortuneOnStartup = Get-UserChoice "Show cow with fortune on terminal startup?" $true

# ── Toggle 2: Lolcat Rainbow ──
Show-Section "Lolcat Rainbow Colors"
$lolcatEnabled = Get-UserChoice "Enable rainbow lolcat colors by default?" $true

# ── Toggle 3: Default Cow File ──
Show-Section "Default Cow File"
$cowFiles = Get-CFCow | Select-Object -First 20
$cowOptions = @('default') + ($cowFiles | Where-Object { $_ -ne 'default' } | Select-Object -First 9)
$defaultCow = Get-UserSelection "Choose default cow:" $cowOptions "default"

# ── Toggle 4: Animation Mode ──
Show-Section "Animation Mode"
$animMode = Get-UserSelection "Choose animation mode:" @('static', 'talking', 'typewriter') "static"

# ── Toggle 5: Shell Aliases ──
Show-Section "Shell Aliases"
$addAliases = Get-UserChoice "Add quick aliases (cowconfig, cowpreview, cowgallery, etc.)?" $true

# ── Toggle 6: Tab Completion ──
Show-Section "Tab Completion"
$addCompletion = Get-UserChoice "Add tab completion for Forgum commands?" $true

# ── Apply Config ──
Show-Section "Applying Configuration"

$config.lolcat.enabled = $lolcatEnabled
$config.cow.file = $defaultCow
$config.animation.mode = $animMode
Set-CFConfig -Config $config
Write-Host "  Config saved" -ForegroundColor Green

# ── Update Profile ──
if (-not $NoProfile) {
    Show-Section "Updating PowerShell Profile"
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (-not $profilePath) { $profilePath = $PROFILE.CurrentUser }
    
    if ($profilePath) {
        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        
        $existingProfile = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }
        $newContent = $existingProfile
        
        # Add Import-Module Forgum
        if ($newContent -notmatch 'Import-Module\s+Forgum') {
            $newContent += "`n`n# Forgum`nImport-Module Forgum -ErrorAction SilentlyContinue"
            Write-Host "  Added Import-Module Forgum" -ForegroundColor Green
        }
        
        # Add Fortune Cow on Startup
        if ($fortuneOnStartup -and $newContent -notmatch 'Show-FortuneCow') {
            $newContent += "`n`n# Forgum Startup Fortune Cow`nif (-not `$global:HKDEVS_STARTUP_DONE) {`n    `$global:HKDEVS_STARTUP_DONE = `$true`n    Show-FortuneCow`n}"
            Write-Host "  Added startup fortune cow" -ForegroundColor Green
        }
        
        # Add Aliases
        if ($addAliases -and $newContent -notmatch 'function cowconfig') {
            $aliasBlock = @'

# Forgum Aliases
function cowconfig { Get-CFConfig | ConvertTo-Json -Depth 4 }
function cowpreview { param([string]$Cow='default',[string]$Text='Hello!') Invoke-Cowsay -Text $Text -CowFile $Cow }
function cowgallery { param([int]$Count=5) Get-CFCow | Get-Random -Count $Count | ForEach-Object { Invoke-Cowsay -Text (Get-Fortune) -CowFile $_ } }
function lolcat-toggle { $c = Get-CFConfig; $c.lolcat.enabled = -not $c.lolcat.enabled; Set-CFConfig -Config $c; Write-Host "Lolcat: $(if ($c.lolcat.enabled){'ON'}else{'OFF'})" }
function cow-animate { param([ValidateSet('static','talking','typewriter')]$Mode) $c = Get-CFConfig; $c.animation.mode = $Mode; Set-CFConfig -Config $c; Write-Host "Animation: $Mode" }
'@
            $newContent += $aliasBlock
            Write-Host "  Added shell aliases" -ForegroundColor Green
        }
        
        # Add Tab Completion
        if ($addCompletion -and $newContent -notmatch 'Register-ArgumentCompleter.*Forgum') {
            $completionBlock = @'

# Forgum Tab Completion
Register-ArgumentCompleter -CommandName Invoke-Cowsay -ParameterName CowFile -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    Get-CFCow | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
'@
            $newContent += $completionBlock
            Write-Host "  Added tab completion" -ForegroundColor Green
        }
        
        Set-Content -Path $profilePath -Value $newContent -Force
        Write-Host "  Profile updated: $profilePath" -ForegroundColor Green
    }
}

# ── Summary ──
Show-Section "Setup Complete!"
Write-Host ""
Write-Host "  Settings applied:" -ForegroundColor White
Write-Host "    Fortune on startup: $fortuneOnStartup" -ForegroundColor Cyan
Write-Host "    Lolcat rainbow:     $lolcatEnabled" -ForegroundColor Cyan
Write-Host "    Default cow:        $defaultCow" -ForegroundColor Cyan
Write-Host "    Animation mode:     $animMode" -ForegroundColor Cyan
Write-Host "    Shell aliases:      $addAliases" -ForegroundColor Cyan
Write-Host "    Tab completion:     $addCompletion" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Restart your terminal to see changes." -ForegroundColor Yellow
Write-Host "  Run 'Invoke-Forgum' to test!" -ForegroundColor Green
Write-Host ""
```

- [ ] **Step 2: Test setup.ps1 in non-interactive mode**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File setup.ps1 -NonInteractive`
Expected: Config saved, profile updated, summary shown

- [ ] **Step 3: Commit**

```bash
git add setup.ps1
git commit -m "feat: add interactive setup script with shell toggles"
```

---

## Task 2: Update `install.ps1` with Figlet Banner and Silent Flag

**Files:**
- Modify: `install.ps1` (lines 20-44 banner, add `-Silent` param)

- [ ] **Step 1: Replace banner with figlet FORGUM**

Replace the `Show-Banner` function (lines 21-44) with:

```powershell
function Show-Banner {
    Write-Host ""
    Write-Host "  _____ _____ ___ _____ ___ ___  _  ___" -ForegroundColor Cyan
    Write-Host " /  ___|  ___/ _ \_   _|_ _/ _ \| |/ /" -ForegroundColor Cyan
    Write-Host " \ \`--. | |_ / /_\ \| |  | | | | ' / " -ForegroundColor Cyan
    Write-Host "  \`--. \|  _||  _  || |  | | | | . \ " -ForegroundColor Cyan
    Write-Host " /\__/ /| |  | | | || | _| |_| | |\ \" -ForegroundColor Cyan
    Write-Host " \____/ \_|  \_| |_/\_/ |___/ \_| |_/ " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  The fun way to get your daily fortune!" -ForegroundColor Magenta
    Write-Host ""
}
```

- [ ] **Step 2: Add -Silent parameter and auto-setup logic**

Add to `param()` block:
```powershell
[switch]$Silent
```

After the profile import section (after line 143), add:

```powershell
# Run setup in silent mode
if ($Silent) {
    Write-Host "  Running setup (silent mode)..." -ForegroundColor White
    $setupScript = Join-Path $PSScriptRoot "setup.ps1"
    if (Test-Path $setupScript) {
        & $setupScript -NonInteractive -Force
    } else {
        Write-Host "  setup.ps1 not found, skipping interactive setup" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "  Run .\setup.ps1 to configure shell integration!" -ForegroundColor Yellow
}
```

- [ ] **Step 3: Test with -Silent flag**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File install.ps1 -Silent`
Expected: Installs module, runs setup with defaults, no prompts

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add -Silent flag to install.ps1, update to figlet banner"
```

---

## Task 3: Update `install.sh` with Figlet Banner

**Files:**
- Modify: `install.sh` (lines 150-164 banner)

- [ ] **Step 1: Replace banner with figlet FORGUM**

Replace the `show_banner()` function (lines 150-164) with:

```bash
show_banner() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
  _____ _____ ___ _____ ___ ___  _  ___
 /  ___|  ___/ _ \_   _|_ _/ _ \| |/ /
 \ `--. | |_ / /_\ \| |  | | | | ' / 
  `--. \|  _||  _  || |  | | | | . \ 
 /\__/ /| |  | | | || | _| |_| | |\ \
 \____/ \_|  \_| |_/\_/ |___/ \_| |_/
EOF
    echo -e "${NC}"
    echo -e "  ${CYAN}${PHRASES[$RANDOM % ${#PHRASES[@]}]}${NC}"
    echo ""
}
```

- [ ] **Step 2: Test install.sh banner**

Run: `bash install.sh` (just check banner displays correctly, Ctrl+C after)

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "feat: update install.sh to figlet banner"
```

---

## Task 4: Create Winget Manifests

**Files:**
- Create: `.agent/winget/manifests/h/HKDEVS/Forgum/1.0.3/HKDEVS.Forgum.yaml`
- Create: `.agent/winget/manifests/h/HKDEVS/Forgum/1.0.3/HKDEVS.Forgum.locale.en-US.yaml`
- Create: `.agent/winget/manifests/h/HKDEVS/Forgum/1.0.3/HKDEVS.Forgum.installer.yaml`

- [ ] **Step 1: Create version manifest**

```yaml
# yaml-language-server: $schema=https://aka.ms/winget-manifest.version.1.12.0.schema.json
PackageIdentifier: HKDEVS.Forgum
PackageVersion: 1.0.3
DefaultLocale: en-US
ManifestType: version
ManifestVersion: 1.12.0
```

- [ ] **Step 2: Create locale manifest**

```yaml
# yaml-language-server: $schema=https://aka.ms/winget-manifest.defaultLocale.1.12.0.schema.json
PackageIdentifier: HKDEVS.Forgum
PackageVersion: 1.0.3
PackageLocale: en-US
Publisher: HKDEVS
PublisherUrl: https://github.com/harish2222
PublisherSupportUrl: https://github.com/harish2222/Forgum/issues
Author: HKDEVS
PackageName: Forgum
PackageUrl: https://github.com/harish2222/Forgum
License: MIT
LicenseUrl: https://github.com/harish2222/Forgum/blob/main/LICENSE
ShortDescription: Cowsay + Fortune + Lolcat PowerShell module with 107 animal cows, rainbow colors, and animations
Description: |
  Forgum is a cross-platform PowerShell module that combines cowsay, fortune, and lolcat
  into one beautiful, configurable, and fun terminal experience. Features 107 animal cows,
  truecolor rainbow colors, 3 animation modes, and multi-shell integration.
Moniker: forgum
Tags:
  - cowsay
  - fortune
  - lolcat
  - ascii
  - rainbow
  - terminal
  - powershell
  - fun
Agreements:
  - AgreementLabel: MIT License
    Agreement: |
      MIT License

      Copyright (c) 2026 HKDEVS

      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:

      The above copyright notice and this permission notice shall be included in all
      copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      SOFTWARE.
    AgreementUrl: https://github.com/harish2222/Forgum/blob/main/LICENSE
ManifestType: defaultLocale
ManifestVersion: 1.12.0
```

- [ ] **Step 3: Create installer manifest**

Note: The InstallerSha256 must be computed from the actual release zip. For now, use a placeholder.

```yaml
# yaml-language-server: $schema=https://aka.ms/winget-manifest.installer.1.12.0.schema.json
PackageIdentifier: HKDEVS.Forgum
PackageVersion: 1.0.3
Platform:
  - Windows.Desktop
MinimumOSVersion: 10.0.17763.0
InstallerType: inno
Scope: user
InstallModes:
  - interactive
  - silent
  - silentWithProgress
UpgradeBehavior: install
Commands:
  - Invoke-Forgum
  - Invoke-Cowsay
  - Get-Fortune
  - Get-CFCow
  - Get-CFConfig
  - Set-CFConfig
  - Show-CFAnimation
Installers:
  - Architecture: x64
    InstallerUrl: https://github.com/harish2222/Forgum/releases/download/v1.0.3/Forgum-v1.0.3-setup.exe
    InstallerSha256: COMPUTE_FROM_RELEASE_ZIP
    InstallerSwitches:
      Silent: /VERYSILENT /NORESTART
      SilentWithProgress: /SILENT /NORESTART
      Custom: /NORESTART
ManifestType: installer
ManifestVersion: 1.12.0
```

- [ ] **Step 4: Validate manifests**

Run: `winget validate .agent/winget/manifests/h/HKDEVS/Forgum/1.0.3/`
Expected: Manifest validation succeeded

- [ ] **Step 5: Commit**

```bash
git add .agent/winget/
git commit -m "feat: add winget manifests for HKDEVS.Forgum v1.0.3"
```

---

## Task 5: Create Scoop Manifest

**Files:**
- Create: `.agent/scoop/bucket/forgum.json`

- [ ] **Step 1: Create scoop manifest**

```json
{
    "version": "1.0.3",
    "description": "Cowsay + Fortune + Lolcat PowerShell module with 107 animal cows",
    "homepage": "https://github.com/harish2222/Forgum",
    "license": "MIT",
    "url": "https://github.com/harish2222/Forgum/releases/download/v1.0.3/Forgum-v1.0.3.zip",
    "hash": "COMPUTE_FROM_RELEASE_ZIP",
    "depends": "pwsh",
    "powershell": {
        "ver": "5.1"
    },
    "installer": {
        "script": [
            "Copy-Item -Path \"$dir\\Forgum\\*\" -Destination \"$env:USERPROFILE\\Documents\\PowerShell\\Modules\\Forgum\" -Recurse -Force",
            "Copy-Item -Path \"$dir\\setup.ps1\" -Destination \"$env:USERPROFILE\\Documents\\PowerShell\\Modules\\Forgum\\setup.ps1\" -Force",
            "& \"$env:USERPROFILE\\Documents\\PowerShell\\Modules\\Forgum\\setup.ps1\" -NonInteractive -Force"
        ]
    },
    "uninstaller": {
        "script": [
            "Remove-Item -Path \"$env:USERPROFILE\\Documents\\PowerShell\\Modules\\Forgum\" -Recurse -Force -ErrorAction SilentlyContinue"
        ]
    },
    "checkver": {
        "github": "https://github.com/harish2222/Forgum"
    },
    "autoupdate": {
        "url": "https://github.com/harish2222/Forgum/releases/download/v$version/Forgum-v$version.zip"
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add .agent/scoop/
git commit -m "feat: add scoop manifest for forgum v1.0.3"
```

---

## Task 6: Update README with Install Instructions

**Files:**
- Modify: `README.md` (Install section)

- [ ] **Step 1: Add winget and scoop install options**

Replace the Install section (lines 91-111) with:

```markdown
---

## Install

### Windows Package Manager (winget)

```powershell
winget install HKDEVS.Forgum
```

### Scoop (Windows)

```powershell
scoop bucket add hkdevs https://github.com/hkdevs/scoop-forgum
scoop install hkdevs/forgum
```

### One-liner (PowerShell)

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1'))
```

### One-liner (Bash/Zsh/Fish)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harish2222/Forgum/main/install.sh)
```

### Manual

```powershell
git clone https://github.com/harish2222/Forgum.git
Import-Module ./Forgum/Forgum.psd1
```

### Post-Install Setup

After installing, run the interactive setup to configure shell integration:

```powershell
.\setup.ps1
```

This will configure:
- Fortune cow on terminal startup
- Rainbow lolcat colors
- Default cow file
- Animation mode
- Shell aliases (cowconfig, cowpreview, cowgallery)
- Tab completion
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add winget and scoop install instructions to README"
```

---

## Task 7: Update Manifest Version

**Files:**
- Modify: `Forgum.psd1` (version and ReleaseNotes)

- [ ] **Step 1: Update version to 1.0.3 and add ReleaseNotes**

```powershell
# In Forgum.psd1, change:
ModuleVersion = '1.0.2'
# To:
ModuleVersion = '1.0.3'

# Add to PSData:
ReleaseNotes = @'
## v1.0.3
- Fixed double output bug in Invoke-Forgum -Lolcat
- Updated all GitHub Actions to Node.js 24 compatible versions
- Added interactive setup script with shell configuration toggles
- Added winget and Scoop package manager support
- Updated Pester minimum to 5.7.0, PSScriptAnalyzer minimum to 1.24.0
- Updated README with figlet banner and demo screenshots
'@
```

- [ ] **Step 2: Commit**

```bash
git add Forgum.psd1
git commit -m "chore: bump version to 1.0.3"
```

---

## Task 8: Create Documentation

**Files:**
- Create: `.agent/winget-submission-guide.md`
- Create: `.agent/scoop-submission-guide.md`
- Create: `.agent/installer-architecture.md`

- [ ] **Step 1: Create winget submission guide**

```markdown
# Winget Submission Guide

## Prerequisites
- Windows 10 build 17763 or later
- `winget` installed (comes with App Installer)
- `wingetcreate` installed: `winget install wingetcreate`
- GitHub account

## Step 1: Compute SHA256 of Release Zip

```powershell
Get-FileHash .\Forgum-v1.0.3.zip -Algorithm SHA256
```

## Step 2: Update Installer Manifest

Update `.agent/winget/manifests/h/HKDEVS/Forgum/1.0.3/HKDEVS.Forgum.installer.yaml`:
- Replace `COMPUTE_FROM_RELEASE_ZIP` with the actual SHA256 hash
- Update `InstallerUrl` to the actual release URL

## Step 3: Validate Manifest

```powershell
winget validate .agent\winget\manifests\h\HKDEVS\Forgum\1.0.3\
```

## Step 4: Test in Windows Sandbox

```powershell
git clone https://github.com/microsoft/winget-pkgs
cd winget-pkgs
powershell .\Tools\SandboxTest.ps1 ..\HKDEVS\Forgum\1.0.3\
```

## Step 5: Fork and Submit

1. Fork https://github.com/microsoft/winget-pkgs
2. Clone your fork with sparse checkout:
   ```powershell
   git clone --filter=blob:none --no-checkout https://github.com/YOUR_USERNAME/winget-pkgs
   cd winget-pkgs
   git sparse-checkout set manifests\h\HKDEVS
   git checkout
   ```
3. Copy manifests to `manifests/h/HKDEVS/Forgum/1.0.3/`
4. Commit and push:
   ```powershell
   git add .
   git commit -m "Add HKDEVS.Forgum v1.0.3"
   git push
   ```
5. Create PR to `microsoft/winget-pkgs` main branch

## Step 6: Monitor PR

Watch for labels:
- `Azure-Pipeline-Passed` — automated tests passed
- `Validation-Completed` — approved and merged
- `Needs-Author-Feedback` — fix required

## Troubleshooting

| Label | Action |
|-------|--------|
| `Error-Hash-Mismatch` | Recompute SHA256, update manifest |
| `Validation-Unattended-Failed` | Ensure installer supports `/VERYSILENT` |
| `Validation-Domain` | Ensure InstallerUrl is from GitHub directly |
| `Binary-Validation-Error` | Check for false positive with antivirus |
```

- [ ] **Step 2: Create scoop submission guide**

```markdown
# Scoop Submission Guide

## Own Bucket (hkdevs/scoop-forgum)

### Step 1: Create GitHub Repo

1. Create repo `hkdevs/scoop-forgum` on GitHub
2. Clone it:
   ```powershell
   git clone https://github.com/hkdevs/scoop-forgum
   cd scoop-forgum
   ```

### Step 2: Add Manifest

Create `bucket/forgum.json` with content from `.agent/scoop/bucket/forgum.json`
Update the `hash` field with actual SHA256.

### Step 3: Test

```powershell
scoop bucket add hkdevs https://github.com/hkdevs/scoop-forgum
scoop install hkdevs/forgum
```

### Step 4: Update Bucket

```powershell
git add .
git commit -m "Update forgum to v1.0.3"
git push
```

## Submit to ScoopInstaller/Extras

### Step 1: Fork Extras

1. Fork https://github.com/ScoopInstaller/Extras
2. Clone with sparse checkout:
   ```powershell
   git clone --filter=blob:none --no-checkout https://github.com/YOUR_USERNAME/Extras
   cd Extras
   git sparse-checkout set bucket
   git checkout
   ```

### Step 2: Add Manifest

Copy `forgum.json` to `bucket/`

### Step 3: Submit PR

```powershell
git add bucket/forgum.json
git commit -m "forgum: add version 1.0.3"
git push
```

Create PR to `ScoopInstaller/Extras` master branch.

## Troubleshooting

- Hash mismatch: Recompute SHA256 of release zip
- Version not detected: Update `checkver` section
- Install fails: Ensure PowerShell 5.1+ is available
```

- [ ] **Step 3: Create installer architecture doc**

```markdown
# Installer Architecture

## Overview

Forgum uses a 3-stage installation model:

1. **install.ps1 / install.sh** — Downloads and extracts module to PowerShell modules directory
2. **setup.ps1** — Configures shell integration (interactive or silent)
3. **Profile update** — Adds Import-Module, fortune cow, aliases, tab completion

## Script Relationships

```
install.ps1 -Silent
  └── setup.ps1 -NonInteractive -Force
        ├── Get-CFConfig / Set-CFConfig
        └── Update $PROFILE

install.sh
  └── (standalone, configures bash/zsh/fish profiles)
```

## Figlet Banner

All scripts display the FORGUM figlet banner on startup:

```
  _____ _____ ___ _____ ___ ___  _  ___
 /  ___|  ___/ _ \_   _|_ _/ _ \| |/ /
 \ `--. | |_ / /_\ \| |  | | | | ' / 
  `--. \|  _||  _  || |  | | | | . \ 
 /\__/ /| |  | | | || | _| |_| | |\ \
 \____/ \_|  \_| |_/\_/ |___/ \_| |_/
```

## Package Manager Integration

### Winget
- InstallerType: `inno` (Inno Setup wrapper)
- Runs: `Forgum-v1.0.3-setup.exe /VERYSILENT /NORESTART`
- Extracts module to `~/Documents/PowerShell/Modules/Forgum/`
- Runs `setup.ps1 -NonInteractive -Force` silently

### Scoop
- Downloads zip from GitHub Release
- Extracts to scoop cache directory
- Copies module to `~/Documents/PowerShell/Modules/Forgum/`
- Runs `setup.ps1 -NonInteractive -Force`

## Setup.ps1 Toggle Flow

```
Show-Banner
  │
  ├─ Check Forgum installed?
  │   └─ No → error, exit
  │
  ├─ Load config (Get-CFConfig)
  │
  ├─ Toggle 1: Fortune on startup? (default: yes)
  ├─ Toggle 2: Lolcat enabled? (default: yes)
  ├─ Toggle 3: Default cow file (default: "default")
  ├─ Toggle 4: Animation mode (default: "static")
  ├─ Toggle 5: Shell aliases? (default: yes)
  ├─ Toggle 6: Tab completion? (default: yes)
  │
  ├─ Apply config (Set-CFConfig)
  │
  └─ Update profile
      ├─ Add Import-Module Forgum
      ├─ Add Show-FortuneCow startup block
      ├─ Add alias functions
      └─ Add Register-ArgumentCompleter
```

## Profile Modification

The setup script modifies `$PROFILE.CurrentUserAllHosts` (or `$PROFILE.CurrentUser` as fallback).

All additions are guarded with existence checks:
- `Import-Module Forgum` — only if not already present
- `Show-FortuneCow` — only if not already present
- Alias functions — only if not already defined
- Tab completion — only if not already registered
```

- [ ] **Step 4: Commit all documentation**

```bash
git add .agent/winget-submission-guide.md .agent/scoop-submission-guide.md .agent/installer-architecture.md
git commit -m "docs: add package manager submission guides and installer architecture"
```

---

## Task 9: Run Full Test Suite

**Files:**
- None (verification only)

- [ ] **Step 1: Run full test suite**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File .agent\run-all-tests-full.ps1`
Expected: ALL PASS (127 tests, lint clean, manifest valid)

- [ ] **Step 2: Commit any fixes if needed**

```bash
git add -A
git commit -m "fix: test fixes after package manager changes"
```

---

## Task 10: Final Push and Tag

- [ ] **Step 1: Push all changes**

```bash
git push origin main
```

- [ ] **Step 2: Tag v1.0.3**

```bash
git tag -a v1.0.3 -m "v1.0.3: Package manager support, setup script, figlet banner"
git push origin v1.0.3
```

- [ ] **Step 3: Verify CI passes**

Wait for CI #39+ to complete, verify all jobs pass.
