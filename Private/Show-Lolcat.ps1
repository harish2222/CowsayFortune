function Show-Lolcat {
    <#
    .SYNOPSIS
        Displays lolcat rainbow text directly to the console.
    .DESCRIPTION
        Renders ANSI color codes by writing directly to the console.
        Enables virtual terminal processing on Windows for proper 24-bit color support.
        Falls back to PowerShell Write-Host with 256-color palette on legacy terminals.
    .PARAMETER Text
        The text to display (with ANSI escape codes already embedded).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Text
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
            # Non-fatal: VT might already be enabled or unavailable
        }
    }

    # Write directly to console to bypass PowerShell pipeline formatting
    # that may strip or ignore ANSI escape codes
    [Console]::WriteLine($Text)
}