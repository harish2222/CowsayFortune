# Contributing to CowsayFortune

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Adding Cows](#adding-cows)
- [Reporting Bugs](#reporting-bugs)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Accept responsibility for mistakes

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```powershell
   git clone https://github.com/YOUR_USERNAME/CowsayFortune.git
   cd CowsayFortune
   ```
3. Create a feature branch:
   ```powershell
   git checkout -b feature/my-feature
   ```
4. Make your changes
5. Run tests
6. Commit and push
7. Create a Pull Request

## Development Setup

### Prerequisites

- PowerShell 5.1+ (Windows) or PowerShell 7+ (cross-platform)
- Git
- Pester (for tests)

### Quick Start

```powershell
# Import the module in development mode
Import-Module ./CowsayFortune/CowsayFortune.psd1 -Force

# Run tests
Import-Module Pester
Invoke-Pester -Path ./Tests/CowsayFortune.Tests.ps1
```

### Project Structure

```
CowsayFortune/
├── CowsayFortune.psd1          # Module manifest
├── CowsayFortune.psm1          # Module entry point
├── Public/                      # Exported functions
│   ├── Invoke-Cowsay.ps1
│   ├── Invoke-CowsayFortune.ps1
│   ├── Get-Fortune.ps1
│   ├── Get-CFCow.ps1
│   ├── Get-CFConfig.ps1
│   ├── Set-CFConfig.ps1
│   └── Show-CFAnimation.ps1
├── Private/                     # Internal functions
│   ├── Get-ConfigPath.ps1
│   ├── Read-CowFile.ps1
│   ├── Read-FortuneFile.ps1
│   ├── Format-CowMessage.ps1
│   ├── Format-Lolcat.ps1
│   └── Animation/
│       ├── Static.ps1
│       ├── Talking.ps1
│       └── Typewriter.ps1
├── Data/
│   ├── Cows/                    # 190 .cow files
│   ├── Fortunes/                # Fortune database
│   └── Templates/               # Default config
├── Tests/                       # Pester tests
├── install.ps1                  # PowerShell installer
├── install.sh                   # Bash installer
└── uninstall.ps1                # Uninstaller
```

## How to Contribute

### Types of Contributions

- **Bug fixes** - Fix issues in existing functionality
- **New features** - Add new capabilities
- **New cows** - Add new cow ASCII art files
- **Documentation** - Improve docs, add examples
- **Performance** - Optimize existing code
- **Tests** - Add or improve test coverage

### Easy First Issues

Look for issues tagged `good-first-issue` on GitHub.

## Coding Standards

### PowerShell Style Guide

```powershell
# Use Approved Verbs
function Get-Something { }    # ✓
function Fetch-Something { }  # ✗

# Use CmdletBinding
function Get-Something {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
}

# Use meaningful parameter names
function Get-Fortune {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Database = 'fortunes'
    )
}

# Include comment-based help
<#
.SYNOPSIS
    Brief description.
.DESCRIPTION
    Detailed description.
.PARAMETER Name
    Parameter description.
.EXAMPLE
    Get-Something -Name "test"
#>
```

### Performance Guidelines

- Use `StringBuilder` for string concatenation in loops
- Cache expensive operations (file reads, config loads)
- Use `List[T]` instead of array `+=` in loops
- Avoid `Write-Host` in functions (use `return` instead)

### Security Guidelines

- Never use `Invoke-Expression` on user input
- Validate all parameters
- Use `ValidateNotNullOrEmpty()` and `ValidatePattern()` where appropriate
- Handle errors gracefully with try/catch

## Testing

### Running Tests

```powershell
# Run all tests
Invoke-Pester -Path ./Tests/CowsayFortune.Tests.ps1

# Run with detailed output
Invoke-Pester -Path ./Tests/CowsayFortune.Tests.ps1 -Verbose

# Run specific test
Invoke-Pester -Path ./Tests/CowsayFortune.Tests.ps1 -TestName "renders cow with message"
```

### Writing Tests

```powershell
Describe "Function Name" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    It "does something" {
        $result = Get-Something -Parameter "value"
        $result | Should Not BeNullOrEmpty
    }

    It "throws for invalid input" {
        $threw = $false
        try { Get-Something -Parameter "" } catch { $threw = $true }
        $threw | Should Be $true
    }
}
```

### Test Coverage

Aim for:
- All public functions tested
- Edge cases covered
- Error conditions tested
- Security scenarios tested

## Pull Request Process

1. **Before submitting:**
   - Run all tests and ensure they pass
   - Follow coding standards
   - Update documentation if needed
   - Add tests for new functionality

2. **PR description should include:**
   - Summary of changes
   - Related issue number
   - Testing done
   - Any breaking changes

3. **Review process:**
   - At least one maintainer approval required
   - All tests must pass
   - No merge conflicts
   - Documentation updated

## Adding Cows

To add a new cow:

1. Create a `.cow` file in `Data/Cows/`
2. Follow the Perl .cow format:
   ```perl
   $the_cow = <<EOC;
         \\   ^__^
          \\  (oo)\\_______
             (__)\\       )\\/\\
                 ||----w |
                 ||     ||
   EOC
   ```
3. Use `$eyes`, `$tongue`, `$thoughts` for customizable parts
4. Test with: `Invoke-Cowsay -Text "Test" -CowFile 'your-cow'`
5. Add to test suite

## Reporting Bugs

1. Check existing issues first
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - PowerShell version
   - OS information

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Open an issue or start a discussion on GitHub.
