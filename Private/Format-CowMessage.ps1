function Format-CowMessage {
    <#
    .SYNOPSIS
        Formats text into a speech balloon with word wrapping.
    .DESCRIPTION
        Wraps text at MaxWidth characters and renders it inside a
        speech balloon with clean ASCII borders.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text,

        [ValidateRange(20, 200)]
        [int]$MaxWidth = 60
    )

    $Text = $Text -replace "`r`n", "`n"

    $lines = [System.Collections.Generic.List[string]]::new()
    $paragraphs = $Text -split '\n'

    foreach ($paragraph in $paragraphs) {
        if ($paragraph.Length -eq 0) {
            $lines.Add('')
            continue
        }

        $words = $paragraph -split ' '
        $sb = [System.Text.StringBuilder]::new()

        foreach ($word in $words) {
            if ($word.Length -eq 0) { continue }
            # Handle words longer than MaxWidth by splitting them
            while ($word.Length -gt $MaxWidth) {
                if ($sb.Length -gt 0) {
                    $lines.Add($sb.ToString())
                    [void]$sb.Clear()
                }
                $lines.Add($word.Substring(0, $MaxWidth))
                $word = $word.Substring($MaxWidth)
            }
            $currentLen = $sb.Length
            if ($currentLen -eq 0) {
                [void]$sb.Append($word)
            }
            elseif ($currentLen + 1 + $word.Length -le $MaxWidth) {
                [void]$sb.Append(' ').Append($word)
            }
            else {
                $lines.Add($sb.ToString())
                [void]$sb.Clear().Append($word)
            }
        }

        if ($sb.Length -gt 0) {
            $lines.Add($sb.ToString())
        }
    }

    if ($lines.Count -eq 0) {
        $lines.Add('')
    }

    $maxLength = 0
    foreach ($line in $lines) {
        if ($line.Length -gt $maxLength) { $maxLength = $line.Length }
    }

    # Clean ASCII balloon with double-line top/bottom
    $result = [System.Collections.Generic.List[string]]::new($lines.Count + 2)
    $topBorder = '#' * ($maxLength + 4)
    $sideBorder = '||'

    $result.Add("  $topBorder")

    if ($lines.Count -eq 1) {
        $pad = ' ' * ($maxLength - $lines[0].Length)
        $result.Add("  $sideBorder $($lines[0])$pad $sideBorder")
    }
    else {
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $pad = ' ' * ($maxLength - $lines[$i].Length)
            $result.Add("  $sideBorder $($lines[$i])$pad $sideBorder")
        }
    }

    $result.Add("  $topBorder")

    return ($result -join "`n")
}
