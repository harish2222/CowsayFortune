# Security Audit

## Overview

Forgum includes a dedicated security test harness with 22 adversarial tests. All pass.

## Threat Model

| Threat | Mitigation | Test Coverage |
|--------|------------|---------------|
| **Code injection via cow files** | Cow templates are parsed as text, never executed as code | Ghost 14, Forgum "does not execute code from cow files" |
| **Shell injection via message text** | Message text is interpolated into bubble string only, never passed to shell | Ghost 06, 07 |
| **Path traversal via cow file name** | Get-CFCow validates against known cow list, throws for unknown | Ghost 15 |
| **Config file tampering** | Corrupted/missing config falls back to safe defaults | Ghost 16, 17 |
| **Null value crashes** | All config fields have null guards and defaults | Ghost 18 |
| **Input length abuse** | 10,000+ character messages handled without crash or hang | Ghost 03, 22 |
| **Unicode/emoji injection** | UTF-8 encoding preserved correctly | Ghost 08 |
| **ANSI escape injection** | Input ANSI codes are preserved, not executed | Ghost 09 |
| **State corruption** | Rapid sequential calls do not corrupt internal state | Ghost 19 |
| **Special characters in JSON config** | Curly braces, quotes, backslashes handled safely | Ghost 10 |

## Security Test Details

### Injection Prevention
- **Shell injection**: Semicolons, pipes, backticks in message text are rendered as literal characters
- **Code execution**: Cow file templates are text-only; `Invoke-Expression` is never called on user input
- **Path traversal**: `Get-CFCow -Name "../../etc/passwd"` throws a descriptive error

### Input Validation
- Empty strings render without crash
- Whitespace-only strings render a valid cow
- 10,000+ character strings complete without hanging
- Unicode emoji (e.g., `🇨🇿`) renders correctly
- ANSI escape sequences in input are preserved, not interpreted

### Config Safety
- Corrupted JSON config file → falls back to defaults
- Config with missing sections → fills in defaults
- Config with null lolcat values → does not crash
- Config changes persist correctly across calls

### Module Isolation
- No global variable pollution
- Config cache is invalidated after Set-CFCow
- Multiple sequential calls do not corrupt internal state

## Known Security Contacts

- **Issues**: https://github.com/harish2222/Forgum/issues
- **Response time**: Issues triaged within 48 hours

## Running Security Tests

```powershell
Import-Module ./Forgum.psd1 -Force
Invoke-Pester -Path ./Tests/Ghost.Tests.ps1 -Output Detailed
```

## No Native Binaries

Forgum is a pure PowerShell module. It contains:
- `.ps1` script files (PowerShell source)
- `.psd1` manifest
- `.psm1` module loader
- `.json` data files (cows, config, fortunes)

**No compiled executables, no DLLs, no native code.**
