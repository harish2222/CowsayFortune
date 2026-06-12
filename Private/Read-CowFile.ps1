function Read-CowFile {
    <#
    .SYNOPSIS
        Reads and parses a .cow template file with caching.
    .DESCRIPTION
        Extracts the $the_cow block from a Perl-format .cow file.
        Handles escape sequences (\@, \$, \\) and caches results for performance.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CowName,

        [string]$CustomPath
    )

    # Check cache first
    $cacheKey = if ($CustomPath) { $CustomPath } else { $CowName }
    if ($script:CowFileCache.ContainsKey($cacheKey)) {
        return $script:CowFileCache[$cacheKey]
    }

    # Resolve path
    if ($CustomPath) {
        $path = $CustomPath
    }
    else {
        $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'
        $path = Join-Path $cowsPath "$CowName.cow"
    }

    if (-not (Test-Path $path)) {
        throw "Cow file not found: $path"
    }

    $content = Get-Content $path -Raw -ErrorAction Stop
    $content = $content -replace "`r`n", "`n"

    # Extract $the_cow heredoc block
    if ($content -match '(?s)\$the_cow\s*=\s*<<["'']?EOC["'']?;\s*(.*?)\s*EOC') {
        $content = $Matches[1]
    }

    # Unescape Perl escape sequences (order matters: \\ before \@ and \$)
    $content = $content -replace '\\\\', '\'
    $content = $content -replace '\\@',  '@'
    $content = $content -replace '\\\$', '$'

    # Cache for subsequent calls
    $script:CowFileCache[$cacheKey] = $content

    return $content
}
