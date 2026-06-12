# Fish Integration

This guide shows you how to use Forgum from the Fish shell. Fish is a popular shell on Mac and Linux known for its user-friendly features.

## How It Works

Fish can't run PowerShell commands directly, but we'll create simple functions that call PowerShell with Forgum.

## Step 1: Make Sure PowerShell is Installed

```fish
# Check if PowerShell is installed
pwsh --version
```

If you see a version number, you're good. If not:
- **Mac**: `brew install powershell`
- **Linux**: See [Microsoft's guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)

## Step 2: Create Forgum Functions

Fish stores its config in `~/.config/fish/config.fish`. Open it:

```fish
nano ~/.config/fish/config.fish
```

Add these lines:

```fish
# ============================================
# Forgum - Fortune Cow for Fish Shell
# ============================================

# Show a cow with a fortune
function forgum
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum"
end

# Show your own message
function cow
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$argv'"
end

# Get just a fortune (no cow)
function fortune-cow
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune"
end

# List available cows
function cows
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFCow | Format-Table -AutoSize"
end

# Rainbow mode toggle
function rainbow
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$config = Get-CFConfig; `$config.lolcat.enabled = -not `$config.lolcat.enabled; Set-CFConfig -Config `$config; Write-Host 'Rainbow: ' -NoNewline; if (`$config.lolcat.enabled) { Write-Host 'ON' -ForegroundColor Magenta } else { Write-Host 'OFF' -ForegroundColor Gray }"
end
```

## Step 3: Save and Reload

```fish
# Reload Fish config
source ~/.config/fish/config.fish
```

## Step 4: Try It!

```fish
# Show a cow with a fortune
forgum

# Your own message
cow Hello World!

# Just a fortune
fortune-cow

# See all cows
cows

# Toggle rainbow
rainbow
```

## Show Fortune on Every Terminal Open

Add this to `~/.config/fish/config.fish`:

```fish
# Show a fortune cow when opening a new terminal
forgum
```

## Advanced: Random Cow on Each Open

```fish
# In ~/.config/fish/config.fish
function random_cow
    set cows default tux dragon cat elephant doge bunny moose whale
    set cow $cows[(random 1 (count $cows))]
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$cow'"
end
random_cow
```

## Advanced: tmux Status Bar

If you use tmux, add this to `~/.tmux.conf`:

```bash
# Show a fortune in the tmux status bar
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null)"
set -g status-interval 300
```

## What Each Command Does

| Command | What It Does |
|:--------|:-------------|
| `pwsh` | Starts PowerShell |
| `-NoProfile` | Doesn't load PowerShell's profile (faster) |
| `-Command` | Runs the following PowerShell code |
| `Import-Module Forgum` | Loads Forgum |
| `Invoke-Forgum` | Shows cow + fortune |
| `Invoke-Cowsay -Text` | Shows cow with your message |
| `Get-Fortune` | Returns just a fortune |
| `Get-CFCow` | Lists all cow characters |

## Troubleshooting

**"pwsh: command not found"**
- PowerShell isn't installed. See Step 1 above.

**"Import-Module : The specified module 'Forgum' was not loaded"**
- Forgum isn't installed. Go to [Getting Started](Getting-Started).

**No output when running `forgum`**
- Try running the pwsh command directly to see error messages.

---

**Back:** [Bash & Zsh Integration](Bash-Zsh-Integration) | **Next:** [tmux Integration →](tmux-Integration)
