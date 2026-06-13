$excludedRules = @(
    'PSReviewUnusedParameter'
    'PSAvoidUsingWriteHost'
    'PSUseSingularNouns'
    'PSUseBOMForUnicodeEncodedFile'
)
$results = Invoke-ScriptAnalyzer -Path . -Recurse -Severity Error,Warning -ExcludeRule $excludedRules
if ($results) {
    Write-Host "FAIL: Found $($results.Count) issue(s):" -ForegroundColor Red
    $results | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize
    exit 1
} else {
    Write-Host "PASS: No lint issues found." -ForegroundColor Green
}
