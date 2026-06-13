#Requires -Version 5.1

# Enable Virtual Terminal Processing for truecolor ANSI support on Windows
if ($IsWindows -or $env:OS -eq 'Windows_NT') {
    try {
        Add-Type @"
            using System;
            using System.Runtime.InteropServices;
            public class VTTerminal {
                [DllImport("kernel32.dll", SetLastError=true)]
                public static extern IntPtr GetStdHandle(int nStdHandle);
                [DllImport("kernel32.dll", SetLastError=true)]
                public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
                [DllImport("kernel32.dll", SetLastError=true)]
                public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
                public const int STD_OUTPUT_HANDLE = -11;
                public const int STD_ERROR_HANDLE  = -12;
                public const uint ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004;
            }
"@ -ErrorAction SilentlyContinue

        $hOut = [VTTerminal]::GetStdHandle([VTTerminal]::STD_OUTPUT_HANDLE)
        $mode = 0
        if ([VTTerminal]::GetConsoleMode($hOut, [ref]$mode)) {
            $newMode = $mode -bor [VTTerminal]::ENABLE_VIRTUAL_TERMINAL_PROCESSING
            [void][VTTerminal]::SetConsoleMode($hOut, $newMode)
        }
    } catch {
        Write-Verbose "Forgum: Virtual Terminal Processing not available: $_"
    }
}

# Module initialization - dot-source private then public functions
$ErrorActionPreference = 'Stop'

$privatePath = Join-Path $PSScriptRoot 'Private'
$publicPath  = Join-Path $PSScriptRoot 'Public'

# Dot-source private functions (order matters for dependencies)
Get-ChildItem -Path $privatePath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        try { . $_.FullName }
        catch { Write-Warning "Forgum: Failed to load $($_.FullName): $_" }
    }

# Dot-source public functions
Get-ChildItem -Path $publicPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        try { . $_.FullName }
        catch { Write-Warning "Forgum: Failed to load $($_.FullName): $_" }
    }

# Module-scoped cache for performance
$script:CowFileCache = @{}
$script:FortuneCache = @{}
$script:ConfigCache  = $null
$script:ConfigCacheTime = [datetime]::MinValue

# Cache TTL in seconds (avoids stale reads during long sessions)
$script:ConfigCacheTTL = 30

# Auto-start: random animated cow with fortune on every import
if ($env:FORGUM_NOAUTOSTART -ne '1') {
    $sb = {
        if (Get-Command Invoke-Forgum -ErrorAction Ignore) {
            $config = Get-CFConfig
            $config.cow.random = $true
            $config.animation.mode = 'talking'
            $config.lolcat.enabled = $true
            $config.lolcat.animate = $true
            Set-CFConfig -Config $config
            $cowText = Invoke-Forgum -Lolcat
            if ($cowText) { [Console]::WriteLine($cowText) }
        }
    }
    & $sb
}
