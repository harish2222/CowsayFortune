if (-not (Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version.Major -ge 5 })) {
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser -MinimumVersion 5.0.0 -MaximumVersion 5.99.99
}

$config = New-PesterConfiguration
$config.Run.Path = './Tests/Forgum.Tests.ps1'
$config.Run.PassThru = $true
$config.Output.Verbosity = 'Detailed'

$results = Invoke-Pester -Configuration $config

Write-Host ""
Write-Host "========================================"
Write-Host ("Tests: {0} | Passed: {1} | Failed: {2} | Skipped: {3}" -f $results.TotalCount, $results.PassedCount, $results.FailedCount, $results.SkippedCount)
Write-Host "========================================"

if ($results.FailedCount -gt 0) {
    $results.TestResult | Where-Object Result -eq 'Failed' | ForEach-Object {
        Write-Host ""
        Write-Host "FAILED: $($_.Name)" -ForegroundColor Red
        Write-Host "  Error: $($_.ErrorRecord.DisplayErrorMessage)" -ForegroundColor Red
        if ($_.ErrorRecord.DisplayErrorStackTrace) {
            Write-Host "  Stack: $($_.ErrorRecord.DisplayErrorStackTrace)" -ForegroundColor DarkRed
        }
    }
    exit 1
}

Write-Host "All tests passed!" -ForegroundColor Green
