Import-Module ./Forgum.psd1 -Force
$config = Get-CFConfig
Write-Host "Current lolcat.enabled: $($config.lolcat.enabled)"
$config.lolcat.enabled = $false
Set-CFConfig -Config $config
Write-Host "Reset lolcat.enabled to false"

# Verify
Import-Module ./Forgum.psd1 -Force
$config2 = Get-CFConfig
Write-Host "After reset: $($config2.lolcat.enabled)"
