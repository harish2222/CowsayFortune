function Format-Lolcat {
    <#
    .SYNOPSIS
        Applies rainbow colorization to text (lolcat algorithm).
    .DESCRIPTION
        Port of the Ruby lolcat sine-wave color algorithm.
        Uses System.Text.StringBuilder for O(n) performance instead of O(n²) string concatenation.
        Supports truecolor (24-bit) and 256-color fallback.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [ValidateRange(0.01, 10.0)]
        [double]$Frequency = 0.1,

        [ValidateRange(0.5, 20.0)]
        [double]$Spread = 3.0,

        [switch]$Truecolor,

        [ValidateRange(0, 10000)]
        [int]$Offset = 0
    )

    # ESC character for ANSI codes (PowerShell 5.1 compatible)
    $esc = [char]27

    # Detect truecolor support
    $useTruecolor = $Truecolor -or ($env:COLORTERM -in @('truecolor', '24bit'))

    $lines = $Text -split "`n"
    $output = [System.Collections.Generic.List[string]]::new($lines.Count)
    $os = $Offset

    foreach ($line in $lines) {
        $sb = [System.Text.StringBuilder]::new($line.Length * 20)

        for ($i = 0; $i -lt $line.Length; $i++) {
            $char = $line[$i]

            # Pass through ANSI escape sequences unchanged
            if ([int][char]$char -eq 27) {
                [void]$sb.Append($char)
                # Consume the rest of the CSI sequence (until a letter terminator)
                for ($j = $i + 1; $j -lt $line.Length; $j++) {
                    [void]$sb.Append($line[$j])
                    if ($line[$j] -match '[A-Za-z]') { $i = $j; break }
                }
                continue
            }

            # Calculate rainbow color using sine waves
            $colorIndex = [int]($os + $i / $Spread)
            $freq = $Frequency * $colorIndex

            $red   = [int]([Math]::Sin($freq) * 127 + 128)
            $green = [int]([Math]::Sin($freq + 2.0943951023931953) * 127 + 128)  # 2PI/3
            $blue  = [int]([Math]::Sin($freq + 4.1887902047863905) * 127 + 128)  # 4PI/3

            if ($useTruecolor) {
                [void]$sb.Append("${esc}[38;2;${red};${green};${blue}m${char}")
            }
            else {
                $r6 = [Math]::Floor($red / 255 * 5)
                $g6 = [Math]::Floor($green / 255 * 5)
                $b6 = [Math]::Floor($blue / 255 * 5)
                $color256 = 16 + 36 * $r6 + 6 * $g6 + $b6
                [void]$sb.Append("${esc}[38;5;${color256}m${char}")
            }
        }

        [void]$sb.Append("${esc}[0m")
        $output.Add($sb.ToString())
        $os++
    }

    return ($output -join "`n")
}
