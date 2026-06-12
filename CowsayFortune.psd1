@{
    RootModule        = 'CowsayFortune.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'f7e6b3a1-2d84-4c9f-a5e0-1b3d7c8f9e2a'
    Author            = 'HKDEVS'
    CompanyName       = 'HKDEVS'
    Copyright         = '(c) 2026 HKDEVS. All rights reserved.'
    Description       = 'Cross-platform cowsay + fortune + lolcat PowerShell module with 107 animal cows, rainbow colors, animations, and multi-shell integration.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Invoke-Cowsay'
        'Invoke-CowsayFortune'
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
            LicenseUri   = 'https://github.com/harish2222/CowsayFortune/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/harish2222/CowsayFortune'
            IconUri      = 'https://raw.githubusercontent.com/harish2222/CowsayFortune/main/icon.png'
            ReleaseNotes = 'Initial release with 107 animal cows, lolcat rainbow, 3 animation modes, multi-shell integration.'
        }
    }
}
