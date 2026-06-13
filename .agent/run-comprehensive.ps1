$config = New-PesterConfiguration
$config.Run.Path = './Tests/Comprehensive.Tests.ps1'
$config.Run.PassThru = $true
$config.Output.Verbosity = 'Detailed'
$results = Invoke-Pester -Configuration $config
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tests: $($results.TotalCount) | Passed: $($results.PassedCount) | Failed: $($results.FailedCount) | Skipped: $($results.SkippedCount)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
if ($results.FailedCount -gt 0) {
    $results.TestResult | Where-Object Result -eq 'Failed' | ForEach-Object {
        Write-Host ""
        Write-Host "FAILED: $($_.Name)" -ForegroundColor Red
        Write-Host "  Error: $($_.ErrorRecord.DisplayErrorMessage)" -ForegroundColor Red
        if ($($_.ErrorRecord.DisplayErrorStackTrace)) {
            Write-Host "  Stack: $($_.ErrorRecord.DisplayErrorStackTrace)" -ForegroundColor DarkRed
        }
    }
    exit 1
}
