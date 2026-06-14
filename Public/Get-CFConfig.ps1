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

    if ($null -eq $config) {
        $defaultPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json'
        if (-not (Test-Path $defaultPath)) {
            $defaultPath = Join-Path $PSScriptRoot 'Data/Templates/default-config.json'
        }
        $config = Get-Content $defaultPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }

    # Ensure all required sections exist with defaults
    $required = $script:DefaultConfigSections
    foreach ($key in $required.Keys) {
        if (-not $config.PSObject.Properties[$key] -or $null -eq $config.$key) {
            $config | Add-Member -NotePropertyName $key -NotePropertyValue ($required[$key] | ConvertTo-Json -Depth 5 | ConvertFrom-Json) -Force
        }
        if ($null -eq $config.$key) { continue }
        foreach ($subKey in $required[$key].Keys) {
            if (-not $config.$key.PSObject.Properties[$subKey] -or $null -eq $config.$key.$subKey) {
                $config.$key | Add-Member -NotePropertyName $subKey -NotePropertyValue $required[$key][$subKey] -Force
            }
        }
    }

    # Cache the result
    $script:ConfigCache = $config
    $script:ConfigCacheTime = $now

    return $config
}
