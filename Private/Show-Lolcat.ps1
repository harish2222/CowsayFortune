function Show-Lolcat {
    <#
    .SYNOPSIS
        Displays lolcat rainbow text directly to the console.
    .DESCRIPTION
        Renders ANSI color codes by writing directly to the console.
        Enables virtual terminal processing on Windows for proper 24-bit color support.
        Supports animated mode with frame-by-frame rendering.
    .PARAMETER Text
        The text to display (with ANSI escape codes already embedded).
    .PARAMETER Animate
        Enable animation mode for psychedelic effects.
    .NOTES
        Based on busyloop/lolcat (BSD-3-Clause) - https://github.com/busyloop/lolcat
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [switch]$Animate
    )

    # Attempt to enable virtual terminal processing on Windows
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
            Write-Verbose "Show-Lolcat: Virtual Terminal Processing not available: $_"
        }
    }

    if ($Animate) {
        # Animation mode: write frames with carriage returns
        # Hide cursor during animation
        [Console]::Write("${esc}[?25l")
        try {
            [Console]::Write($Text)
            [Console]::Write("${esc}[0m")
        } finally {
            # Show cursor after animation
            [Console]::Write("${esc}[?25h${esc}[0m")
        }
    } else {
        # Plain mode: write directly to console
        [Console]::WriteLine($Text)
    }
}
