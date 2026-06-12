function Get-ConfigPath {
    <#
    .SYNOPSIS
        Returns the cross-platform config file path.
    .DESCRIPTION
        Checks COWSAYFORTUNE_CONFIG env var first, then uses platform-appropriate defaults.
    #>
    [CmdletBinding()]
    param()

    if ($env:COWSAYFORTUNE_CONFIG) {
        return $env:COWSAYFORTUNE_CONFIG
    }

    if ($IsLinux -or $IsMacOS) {
        return Join-Path (Join-Path $HOME '.config') 'cowsayfortune/config.json'
    }

    if ($IsWindows -or $env:OS -eq 'Windows_NT') {
        return Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell/cowsayfortune/config.json'
    }

    return Join-Path (Join-Path $HOME '.config') 'cowsayfortune/config.json'
}
