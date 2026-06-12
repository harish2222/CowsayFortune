@{
    RootModule        = 'CowsayFortune.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'HKDEVS'
    CompanyName       = 'HKDEVS'
    Copyright         = '(c) 2026 HKDEVS. All rights reserved.'
    Description       = 'Cross-platform cowsay + fortune + lolcat PowerShell module with 190 cows, rainbow colors, animations, and multi-shell integration.'
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
            LicenseUri   = 'https://github.com/HKDEVS/CowsayFortune/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/HKDEVS/CowsayFortune'
            IconUri      = 'https://github.com/HKDEVS/CowsayFortune/main/icon.png'
            ReleaseNotes = 'Initial release with 190 cows, lolcat rainbow, 3 animation modes, multi-shell integration.'
        }
    }
}
