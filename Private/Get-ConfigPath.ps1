function Get-ConfigPath {
    <#
    .SYNOPSIS
        Returns the cross-platform config file path.
    .DESCRIPTION
        Checks Forgum_CONFIG env var first, then uses platform-appropriate defaults.
    #>
    [CmdletBinding()]
    param()

    if ($env:Forgum_CONFIG) {
        return $env:Forgum_CONFIG
    }

    if ($IsLinux -or $IsMacOS) {
        return Join-Path (Join-Path $HOME '.config') 'Forgum/config.json'
    }

    if ($IsWindows -or $env:OS -eq 'Windows_NT') {
        return Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell/Forgum/config.json'
    }

    return Join-Path (Join-Path $HOME '.config') 'Forgum/config.json'
}
