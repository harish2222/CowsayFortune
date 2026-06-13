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
    $required = @{
        animation = @{ mode = 'static'; speed = 20; duration = 12; spread = 3.0 }
        cow = @{ file = 'default'; random = $false; mode = $null; eyes = 'oo'; tongue = '  ' }
        fortune = @{ database = 'fortunes'; offensive = $false }
        lolcat = @{ enabled = $false; truecolor = $true; frequency = 0.1; spread = 3.0; seed = 0; invert = $false; animate = $false; duration = 12; speed = 20.0 }
        output = @{ wordWrap = $true; maxWidth = 60 }
        startup = @{ enabled = $true; command = 'Invoke-Forgum' }
        shell = @{ integration = 'auto'; tmux = @{ enabled = $false; pane = 'status-right' } }
    }
    foreach ($key in $required.Keys) {
        if (-not $config.PSObject.Properties[$key] -or $null -eq $config.$key) {
            $config | Add-Member -NotePropertyName $key -NotePropertyValue ($required[$key] | ConvertTo-Json -Depth 5 | ConvertFrom-Json) -Force
        }
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
