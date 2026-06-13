# Plan: Fix Lolcat Rainbow Color Feature

## Root Cause Analysis

Two interlocking bugs prevent rainbow colors from displaying:

### Bug 1: `Invoke-Cowsay.ps1` — returns nothing when lolcat is enabled
- When `-Lolcat` is passed, calls `Show-Lolcat` internally, then falls through with no `return`
- Caller (`Invoke-Forgum`) receives `$null` instead of colorized string

### Bug 2: `Invoke-Forgum.ps1` — ignores `config.lolcat.enabled`
- Only checks `-Lolcat` switch parameter, never reads `$config.lolcat.enabled`
- Tests set config but don't pass `-Lolcat` switch
- Removed `Show-CFAnimation` call and `return` statement

## Fix Steps

### Step 1: Fix `Invoke-Cowsay.ps1`
- Remove `Show-Lolcat` call — be a pure data function
- Always `return $output` regardless of lolcat state
- When lolcat on: apply `Format-Lolcat`, return colorized string
- Restore `[OutputType([string])]`

### Step 2: Fix `Invoke-Forgum.ps1`
- Determine effective lolcat: `$useLolcat = $Lolcat -or $config.lolcat.enabled`
- Pass lolcat to `Invoke-Cowsay` when appropriate
- Display: `Show-Lolcat` when lolcat on, `Write-Host` otherwise
- Restore `Show-CFAnimation` call
- Always `return $cowOutput`

### Step 3: Verify tests pass locally
### Step 4: Commit and push to trigger CI/CD
### Step 5: Monitor CI across all 3 platforms

## Key Files
| File | Change |
|------|--------|
| `Public/Invoke-Cowsay.ps1` | Remove `Show-Lolcat`, always return string |
| `Public/Invoke-Forgum.ps1` | Check config, restore animation, return output |

## Expected Test Results
- Truecolor ANSI codes (`\e[38;2;R;G;Bm`) present when lolcat enabled
- 256-color ANSI codes (`\e[38;5;Nm`) when truecolor disabled
- No ANSI codes when lolcat disabled
