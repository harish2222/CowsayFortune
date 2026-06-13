Import-Module ./Forgum.psd1 -Force

# Set lolcat disabled
$config = Get-CFConfig
$config.lolcat.enabled = $false
Set-CFConfig -Config $config

# Re-import to clear cache
Import-Module ./Forgum.psd1 -Force

# Test Invoke-Forgum output
$output = Invoke-Forgum
Write-Host "Output type: $($output.GetType().Name)"
Write-Host "Output length: $($output.Length)"
Write-Host "Output is null: $($null -eq $output)"
Write-Host "Output first 100 chars: $($output.Substring(0, [Math]::Min(100, $output.Length)))"

$esc = [char]27
$hasAnsi = $output -match "${esc}\[[0-9;]*m"
Write-Host "hasAnsi value: $hasAnsi"
Write-Host "hasAnsi type: $($hasAnsi.GetType().Name)"
