<#
.SYNOPSIS
    Uninstalls Forgum module.
.DESCRIPTION
    Removes the module, config, and shell integration.
.EXAMPLE
    .\uninstall.ps1
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

Write-Host ""
Write-Host "  Forgum Uninstaller" -ForegroundColor Cyan
Write-Host ""

# Remove module
$installDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum"
if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
    Write-Host "  Removed module: $installDir" -ForegroundColor Green
}

# Remove config
$configDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Forgum"
if (Test-Path $configDir) {
    Remove-Item $configDir -Recurse -Force
    Write-Host "  Removed config: $configDir" -ForegroundColor Green
}

# Remove from profile
$profilePath = $PROFILE.CurrentUserAllHosts
if (Test-Path $profilePath) {
    $content = Get-Content $profilePath -Raw
    if ($content -match 'Forgum') {
        $newContent = $content -replace '(?s)\n*# Forgum\nImport-Module Forgum[^\n]*\n*', "`n"
        Set-Content -Path $profilePath -Value $newContent.TrimEnd()
        Write-Host "  Removed from PowerShell profile" -ForegroundColor Green
    }
}

# Remove from bash/zsh/fish
foreach ($file in @("$HOME/.bashrc", "$HOME/.zshrc", "$HOME/.config/fish/config.fish")) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match 'Forgum') {
            $newContent = $content -replace '(?s)\n*# Forgum\n.*?Forgum.*?\n*', "`n"
            Set-Content -Path $file -Value $newContent.TrimEnd()
            Write-Host "  Removed from $file" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "  Forgum uninstalled successfully!" -ForegroundColor Green
Write-Host ""
