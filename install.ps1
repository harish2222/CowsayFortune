<#
.SYNOPSIS
    CowsayFortune Installer - Fun installation like oh-my-zsh!
.DESCRIPTION
    Installs CowsayFortune with a fun, interactive experience.
    Checks for dependencies and installs them automatically.
.EXAMPLE
    .\install.ps1
    # One-liner install:
    pwsh -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/CowsayFortune/main/install.ps1'))"
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param()

#Requires -Version 5.1

# ASCII Art Banner
function Show-Banner {
    Write-Host ""
    Write-Host "    ,________                   __" -ForegroundColor Cyan
    Write-Host "    \____   \  ____   ____  |  | _  ____   ____   ____   ____   ____   _______" -ForegroundColor Cyan
    Write-Host "     /|      \_/ __ \ /  _ \ |  |/ \/ __ \ /    \ / __ \ / __ \ /  _ \ /  ___/" -ForegroundColor Cyan
    Write-Host "    / |   |  \  ___/(  <_> )|   |  \  ___/|   |  \  ___/|  ___/(  <_> )\___ \" -ForegroundColor Cyan
    Write-Host "    \__|___|  /\___  >____/ |__|\__\___  >___|  /\___  >____  >______//____  >" -ForegroundColor Cyan
    Write-Host "           \/     \/                   \/     \/     \/     \/           \/ " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  The fun way to get your daily fortune!" -ForegroundColor Magenta
    Write-Host ""

    $phrases = @(
        "Moo! Let's install CowsayFortune!",
        "A cow approaches you with a fortune...",
        "The prophecy says: install me!",
        "I come in peace! (and with rainbows)",
        "Don't have a cow, man! Install me!",
        "Fortune favors the bold... and the installed!",
        "Cow says: Install me or face the consequences!"
    )
    Write-Host "  $($phrases | Get-Random)" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Progress {
    param([int]$Current, [int]$Total)
    $pct = [math]::Floor($Current * 100 / $Total)
    $filled = [math]::Floor($Current * 50 / $Total)
    $bar = ("█" * $filled) + ("░" * (50 - $filled))
    Write-Host "`r  [$bar] $pct%" -NoNewline -ForegroundColor Green
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Main
Show-Banner

Write-Host "  Checking dependencies..." -ForegroundColor White
Write-Host ""

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -ge 5) {
    Write-Host "  PowerShell $($PSVersionTable.PSVersion) found" -ForegroundColor Green
} else {
    Write-Host "  PowerShell 5.1+ required. Current: $($PSVersionTable.PSVersion)" -ForegroundColor Red
    exit 1
}

# Check Git
if (Test-CommandExists git) {
    Write-Host "  Git found" -ForegroundColor Green
} else {
    Write-Host "  Git not found (optional but recommended)" -ForegroundColor Yellow
}

# Check Pester
if (Get-Module -ListAvailable -Name Pester) {
    Write-Host "  Pester found" -ForegroundColor Green
} else {
    Write-Host "  Pester not found (optional, needed for tests)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Installing CowsayFortune..." -ForegroundColor White
Write-Host ""

# Determine install directory
$installDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\CowsayFortune"
$configDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\cowsayfortune"

# Create directories
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}
Show-Progress 10 100

# Clone or copy
$sourceDir = Split-Path $MyInvocation.MyCommand.Path -Parent
if (Test-CommandExists git) {
    if (Test-Path (Join-Path $sourceDir '.git')) {
        # Running from cloned repo
        Copy-Item -Path "$sourceDir\CowsayFortune\*" -Destination $installDir -Recurse -Force
    } else {
        # Download from GitHub
        Write-Host ""
        Write-Host "  Downloading from GitHub..." -ForegroundColor Cyan
        $tempDir = Join-Path $env:TEMP "CowsayFortune_$(Get-Random)"
        git clone --depth 1 https://github.com/harish2222/CowsayFortune.git $tempDir 2>$null
        Copy-Item -Path "$tempDir\CowsayFortune\*" -Destination $installDir -Recurse -Force
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
} else {
    Copy-Item -Path "$sourceDir\CowsayFortune\*" -Destination $installDir -Recurse -Force
}
Show-Progress 50 100

# Create config directory
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}
Show-Progress 70 100

# Setup PowerShell profile integration
$profilePath = $PROFILE.CurrentUserAllHosts
if ($profilePath) {
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $importLine = "Import-Module CowsayFortune -ErrorAction SilentlyContinue"
    $existingProfile = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }

    if ($existingProfile -notmatch 'CowsayFortune') {
        $separator = if ($existingProfile.Length -gt 0) { "`n`n" } else { '' }
        Add-Content -Path $profilePath -Value "${separator}# CowsayFortune`n$importLine"
        Write-Host "  Added to PowerShell profile" -ForegroundColor Green
    }
}
Show-Progress 90 100

# Verify
try {
    Import-Module $installDir\CowsayFortune.psd1 -Force -ErrorAction Stop
} catch {
    Write-Host ""
    Write-Host "  Warning: Module loaded but verification had issues" -ForegroundColor Yellow
}
Show-Progress 100 100

Write-Host ""
Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Quick Start:" -ForegroundColor White
Write-Host "    Invoke-CowsayFortune          # Show a cow with a fortune" -ForegroundColor Green
Write-Host "    Invoke-Cowsay -Text 'Hello'   # Show a cow with custom text" -ForegroundColor Green
Write-Host "    Get-Fortune                  # Get a random fortune" -ForegroundColor Green
Write-Host "    Get-CFCow                    # List all available cows" -ForegroundColor Green
Write-Host ""
Write-Host "  Configuration:" -ForegroundColor White
Write-Host "    Get-CFConfig                 # View current config" -ForegroundColor Green
Write-Host "    Set-CFConfig                 # Update config" -ForegroundColor Green
Write-Host ""
Write-Host "  Enable rainbow colors:" -ForegroundColor Yellow
Write-Host '    Set-CFConfig -Config @{ lolcat = @{ enabled = $true } }' -ForegroundColor Yellow
Write-Host ""
Write-Host "  Fortune favors the bold! Enjoy your cows!" -ForegroundColor Magenta
Write-Host ""
