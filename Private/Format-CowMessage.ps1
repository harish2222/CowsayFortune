function Format-CowMessage {
    <#
    .SYNOPSIS
        Formats text into a speech balloon with word wrapping.
    .DESCRIPTION
        Wraps text at MaxWidth characters and renders it inside a
        classic ASCII speech balloon with top/bottom borders.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text,

        [ValidateRange(20, 200)]
        [int]$MaxWidth = 60,

        [switch]$Think
    )

    # Normalize line endings
    $Text = $Text -replace "`r`n", "`n"

    # Word-wrap using System.Text.StringBuilder for performance
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

    # Find max line length
    $maxLength = 0
    foreach ($line in $lines) {
        if ($line.Length -gt $maxLength) { $maxLength = $line.Length }
    }

    # Build balloon
    $padding = ' ' * ($maxLength + 2)
    $result = [System.Collections.Generic.List[string]]::new()
    $result.Add(" $('_' * ($maxLength + 2))")

    $openChar  = if ($Think) { '(' } else { '<' }
    $closeChar = if ($Think) { ')' } else { '>' }
    $midOpen   = if ($Think) { '(' } else { '|' }
    $midClose  = if ($Think) { ')' } else { '|' }

    if ($lines.Count -eq 1) {
        $pad = ' ' * ($maxLength - $lines[0].Length)
        $result.Add("$openChar $($lines[0])$pad $closeChar")
    }
    else {
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $pad = ' ' * ($maxLength - $lines[$i].Length)
            if ($i -eq 0) {
                $result.Add("/ $($lines[$i])$pad \")
            }
            elseif ($i -eq $lines.Count - 1) {
                $result.Add("\ $($lines[$i])$pad /")
            }
            else {
                $result.Add("$midOpen $($lines[$i])$pad $midClose")
            }
        }
    }

    $result.Add(" $('-' * ($maxLength + 2))")

    return ($result -join "`n")
}
