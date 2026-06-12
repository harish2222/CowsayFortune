function Get-CFConfig {
    <#
    .SYNOPSIS
        Returns the current Forgum configuration.
    .DESCRIPTION
        Loads config from disk (with caching) or returns defaults.
        Config is cached for 30 seconds to avoid repeated disk reads.
    .EXAMPLE
        Get-CFConfig
        Returns the full configuration object.
    .EXAMPLE
        (Get-CFConfig).lolcat.enabled
        Returns just the lolcat enabled setting.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    # Return cached config if still valid
    $now = [datetime]::UtcNow
    if ($null -ne $script:ConfigCache -and
        ($now - $script:ConfigCacheTime).TotalSeconds -lt $script:ConfigCacheTTL) {
        return $script:ConfigCache
    }

    $path = Get-ConfigPath

    if (Test-Path $path) {
        try {
            $config = Get-Content $path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            Write-Warning "Forgum: Corrupt config file, using defaults. Error: $($_.Exception.Message)"
            $config = $null
        }
    }

    if (-not $config) {
        $defaultPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json'
        if (-not (Test-Path $defaultPath)) {
            $defaultPath = Join-Path $PSScriptRoot 'Data/Templates/default-config.json'
        }
        $config = Get-Content $defaultPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }

    # Ensure all required sections exist with defaults
    if (-not $config.animation) { $config | Add-Member -NotePropertyName animation -NotePropertyValue ([PSCustomObject]@{ mode = 'static'; speed = 20; duration = 12; spread = 3.0 }) -Force }
    if (-not $config.cow) { $config | Add-Member -NotePropertyName cow -NotePropertyValue ([PSCustomObject]@{ file = 'default'; random = $false; mode = $null; eyes = 'oo'; tongue = '  ' }) -Force }
    if (-not $config.fortune) { $config | Add-Member -NotePropertyName fortune -NotePropertyValue ([PSCustomObject]@{ database = 'fortunes'; offensive = $false }) -Force }
    if (-not $config.lolcat) { $config | Add-Member -NotePropertyName lolcat -NotePropertyValue ([PSCustomObject]@{ enabled = $false; truecolor = $true; frequency = 0.1; invert = $false }) -Force }
    if (-not $config.output) { $config | Add-Member -NotePropertyName output -NotePropertyValue ([PSCustomObject]@{ wordWrap = $true; maxWidth = 60 }) -Force }
    if (-not $config.shell) { $config | Add-Member -NotePropertyName shell -NotePropertyValue ([PSCustomObject]@{ integration = 'auto'; tmux = ([PSCustomObject]@{ enabled = $false; pane = 'status-right' }) }) -Force }

    # Cache the result
    $script:ConfigCache = $config
    $script:ConfigCacheTime = $now

    return $config
}
