#Requires -Version 5.1

# Module initialization - dot-source private then public functions
$ErrorActionPreference = 'Stop'

$privatePath = Join-Path $PSScriptRoot 'Private'
$publicPath  = Join-Path $PSScriptRoot 'Public'

# Dot-source private functions (order matters for dependencies)
Get-ChildItem -Path $privatePath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

# Dot-source public functions
Get-ChildItem -Path $publicPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

# Module-scoped cache for performance
$script:CowFileCache = @{}
$script:FortuneCache = @{}
$script:ConfigCache  = $null
$script:ConfigCacheTime = [datetime]::MinValue

# Cache TTL in seconds (avoids stale reads during long sessions)
$script:ConfigCacheTTL = 30

$ErrorActionPreference = 'Continue'
