# Bash & Zsh Integration

This guide shows you how to use Forgum from Bash or Zsh shells. Forgum is a PowerShell module, but you can call it from any shell!

## How It Works

Bash and Zsh can't run PowerShell commands directly, but they can call PowerShell with a command. We'll set up a simple shortcut.

## Step 1: Make Sure PowerShell is Installed

```bash
# Check if PowerShell is installed
pwsh --version
```

If you see a version number, you're good. If not, install PowerShell first:
- **Mac**: `brew install powershell`
- **Linux**: See [Microsoft's guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)

## Step 2: Find Your Shell Config

```bash
# For Bash
echo $HOME/.bashrc

# For Zsh
echo $HOME/.zshrc
```

## Step 3: Add Forgum Functions

Open your config file:

```bash
# For Bash
nano ~/.bashrc

# For Zsh
nano ~/.zshrc
```

Add these lines at the end:

```bash
# ============================================
# Forgum - Fortune Cow for Bash/Zsh
# ============================================

# Show a cow with a fortune
forgum() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum"
}

# Show your own message
cow() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$*'"
}

# Get just a fortune (no cow)
fortune-cow() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune"
}

# List available cows
cows() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFCow | Format-Table -AutoSize"
}

# Rainbow mode toggle
rainbow() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$config = Get-CFConfig; `$config.lolcat.enabled = -not `$config.lolcat.enabled; Set-CFConfig -Config `$config; Write-Host 'Rainbow: ' + (if (`$config.lolcat.enabled) {'ON'} else {'OFF'})"
}
```

## Step 4: Save and Reload

```bash
# For Bash
source ~/.bashrc

# For Zsh
source ~/.zshrc
```

## Step 5: Try It!

```bash
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

Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
# Show a fortune cow when opening a new terminal
forgum
```

## Advanced: Random Cow on Each Open

```bash
# In ~/.bashrc or ~/.zshrc
random_cow() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale")
    local cow=${cows[$RANDOM % ${#cows[@]}]}
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$cow'"
}
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

**Back:** [PowerShell Integration](PowerShell-Integration) | **Next:** [Fish Integration →](Fish-Integration)
