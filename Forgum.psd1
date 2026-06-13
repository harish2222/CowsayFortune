@{
    RootModule        = 'Forgum.psm1'
    ModuleVersion     = '1.0.5'
    GUID              = 'f7e6b3a1-2d84-4c9f-a5e0-1b3d7c8f9e2a'
    Author            = 'HKDEVS'
    CompanyName       = 'HKDEVS'
    Copyright         = '(c) 2026 HKDEVS. All rights reserved.'
    Description       = 'Cross-platform cowsay + fortune + lolcat PowerShell module with 107 animal cows, rainbow colors, animations, and multi-shell integration.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Invoke-Cowsay'
        'Invoke-Forgum'
        'Get-Fortune'
        'Get-CFCow'
        'Get-CFConfig'
        'Set-CFConfig'
        'Show-CFAnimation'
    )
    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('cowsay', 'fortune', 'lolcat', 'ascii', 'fun', 'cross-platform', 'terminal')
            LicenseUri   = 'https://github.com/harish2222/Forgum/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/harish2222/Forgum'
            IconUri      = 'https://raw.githubusercontent.com/harish2222/Forgum/main/icon.png'
            ReleaseNotes = @'
## v1.0.5
- Inno Setup installer for winget compatibility (EXE, no admin required)
- One-liner install via /VERYSILENT flag
- CI builds both ZIP and Setup.exe for releases
- Winget manifests corrected (InstallerType: inno)

## v1.0.4
- Complete sample configurations for all platforms (PowerShell, Bash, Zsh, Fish, Git-Bash)
- Wiki documentation: Sample-Configs.md with 9 use cases across 5 shells
- Platform-specific integration guides with full code blocks
- Package manager manifest validation tests
- Documentation existence tests
- Security harness tests (no Invoke-Expression, safe config paths, safe cow files)
- Proof of legitimacy documentation for package manager reviewers
- Winget submission (PR #387476)
- Scoop submission (PR #18034)
- Fixed Show-FortuneCow function not defined in setup.ps1 generated profiles
- Fixed double output bug in Invoke-Forgum -Lolcat
- Fixed duplicate tab completion blocks in profile.ps1
- Fixed missing parameter names in cowpreview/cowgallery functions
- Fixed lolcat toggle not displaying current state
- Moved package manager docs from hidden .agent/ to visible package-managers/
- Updated all documentation with platform-specific samples
- Expanded test suite with security and package manager coverage
'@
        }
    }
}
