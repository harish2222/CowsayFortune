@{
    RootModule        = 'Forgum.psm1'
    ModuleVersion     = '1.1.0'
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
            ReleaseNotes = 'v1.1.0: Added profile customization functions, comprehensive customization guide, advanced contributor methods.'
        }
    }
}
