# PowerShell Integration

This guide shows you how to make Forgum part of your PowerShell experience. After this, Forgum will greet you every time you open PowerShell.

## What is a PowerShell Profile?

Your PowerShell profile is a special file that runs automatically when you open PowerShell. Think of it like a "startup script" — anything you put in there runs every time.

## Step 1: Find Your Profile

Open PowerShell and type:

```powershell
$PROFILE
```

This shows you the path to your profile file. It's usually something like:
- **Windows**: `C:\Users\YourName\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- **Mac/Linux**: `~/.config/powershell/Microsoft.PowerShell_profile.ps1`

## Step 2: Open Your Profile

```powershell
# Open in Notepad (Windows)
notepad $PROFILE

# Open in VS Code (any platform)
code $PROFILE

# Open in Vim (Mac/Linux)
vim $PROFILE
```

If PowerShell says the file doesn't exist, create it:

```powershell
New-Item -ItemType File -Path $PROFILE -Force
```

## Step 3: Add Forgum

Copy and paste these lines into your profile file:

```powershell
# ============================================
# Forgum - Fortune Cow for PowerShell
# ============================================

# Import the module
Import-Module Forgum -ErrorAction SilentlyContinue

# Show a cow with a random fortune when PowerShell starts
Invoke-Forgum
```

## Step 4: Save and Restart

1. Save the file (Ctrl+S in most editors)
2. Close PowerShell
3. Open PowerShell again

You should see a cow with a fortune!

## Advanced Profile Setups

### Setup 1: Fortune Every Time (Simple)

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue
Invoke-Forgum
```

### Setup 2: Random Cow Every Time

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue

# Pick a random cow and show a fortune
$cows = Get-CFCow
$randomCow = $cows | Get-Random
Invoke-Forgum -CowFile $randomCow.Name
```

### Setup 3: Different Cow for Each Day

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue

# Use day of year to pick a consistent cow for the day
$cows = Get-CFCow
$dayCow = $cows[(Get-Date).DayOfYear % $cows.Count]
Invoke-Forgum -CowFile $dayCow.Name
```

### Setup 4: Rainbow Mode

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue

# Enable rainbow colors
$config = Get-CFConfig
$config.lolcat.enabled = $true
Set-CFConfig -Config $config

Invoke-Forgum
```

### Setup 5: Quiet Mode (Only on First Open)

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue

# Only show fortune if this is the first PowerShell window
$hostWindow = (Get-Process -Id $PID).MainWindowTitle
if ($hostWindow -eq 'Windows PowerShell' -or $hostWindow -eq 'pwsh') {
    Invoke-Forgum
}
```

## Custom Profile Functions

Add these handy shortcuts to your profile:

```powershell
# Quick fortune
function ff { Invoke-Forgum }

# Fortune with a specific cow
function fc { param([string]$Cow) Invoke-Forgum -CowFile $Cow }

# Toggle rainbow
function lolcat {
    $config = Get-CFConfig
    $config.lolcat.enabled = -not $config.lolcat.enabled
    Set-CFConfig -Config $config
    Write-Host "Rainbow: $(if ($config.lolcat.enabled) {'ON'} else {'OFF'})" -ForegroundColor $(if ($config.lolcat.enabled) {'Magenta'} else {'Gray'})
}

# Random cow gallery (shows 3 cows)
function cowgallery {
    Get-CFCow | Get-Random -Count 3 | ForEach-Object {
        Invoke-Cowsay -Text (Get-Fortune) -CowFile $_.Name
    }
}
```

## What Each Line Does

| Line | What It Does |
|:-----|:-------------|
| `Import-Module Forgum` | Loads Forgum into PowerShell |
| `-ErrorAction SilentlyContinue` | Ignores errors if Forgum isn't installed |
| `Invoke-Forgum` | Shows a cow with a random fortune |
| `Get-CFConfig` | Reads the current settings |
| `Set-CFConfig` | Saves new settings |

## Troubleshooting

**"Import-Module : The specified module 'Forgum' was not loaded"**
- Forgum isn't installed yet. Go back to [Getting Started](Getting-Started).

**"Invoke-Forgum : The term 'Invoke-Forgum' is not recognized"**
- The import line might have an error. Check for typos.

**No cow appears on startup**
- Make sure `Invoke-Forgum` is on its own line in your profile.
- Restart PowerShell to test.

---

**Back:** [Getting Started](Getting-Started) | **Next:** [Bash & Zsh Integration →](Bash-Zsh-Integration)
