Import-Module ./Forgum.psd1 -Force
$r = Invoke-Pester -Path './Tests/Forgum.Tests.ps1' -PassThru
Write-Host "Failed: $($r.FailedCount)"
if ($r.FailedCount -gt 0) {
    $r.Failed | ForEach-Object {
        Write-Host "TEST: $($_.Name)"
        Write-Host "MSG: $($_.FailureMessage)"
    }
}