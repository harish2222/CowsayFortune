Import-Module ./Forgum.psd1 -Force
$r1 = Invoke-Pester -Path './Tests/Forgum.Tests.ps1' -PassThru
Write-Host "Forgum.Tests: Passed=$($r1.PassedCount), Failed=$($r1.FailedCount)"

$r2 = Invoke-Pester -Path './Tests/Comprehensive.Tests.ps1' -PassThru
Write-Host "Comprehensive.Tests: Passed=$($r2.PassedCount), Failed=$($r2.FailedCount)"

$r3 = Invoke-Pester -Path './Tests/Ghost.Tests.ps1' -PassThru
Write-Host "Ghost.Tests: Passed=$($r3.PassedCount), Failed=$($r3.FailedCount)"

$totalPassed = $r1.PassedCount + $r2.PassedCount + $r3.PassedCount
$totalFailed = $r1.FailedCount + $r2.FailedCount + $r3.FailedCount
Write-Host "TOTAL: Passed=$totalPassed, Failed=$totalFailed"