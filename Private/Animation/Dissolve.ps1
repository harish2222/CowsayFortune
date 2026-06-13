function Invoke-DissolveAnimation {
    <#
    .SYNOPSIS
        Cow materializes character by character in random positions.
    .DESCRIPTION
        Creates a "teleportation" or "materialization" effect — characters
        appear randomly across the canvas until the full cow is revealed.
        Each frame adds more characters, building up from noise to clarity.
        Uses cursor repositioning for smooth, flicker-free rendering.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(1, 20)]
        [int]$Speed = 5,

        [ValidateRange(3, 100)]
        [int]$Duration = 15
    )

    $lines = $CowOutput -split "`n"
    $maxLen = 0
    foreach ($line in $lines) {
        if ($line.Length -gt $maxLen) { $maxLen = $line.Length }
    }
    $lineCount = $lines.Count

    # Pad all lines to equal length
    $paddedLines = @()
    foreach ($line in $lines) {
        $paddedLines += $line.PadRight($maxLen)
    }

    # Build character grid as nested arrays (PS 5.1 compatible)
    $charGrid = @()
    for ($r = 0; $r -lt $lineCount; $r++) {
        $row = @()
        for ($c = 0; $c -lt $maxLen; $c++) {
            $row += $paddedLines[$r][$c]
        }
        $charGrid += ,$row
    }

    # Create shuffled list of all positions
    $totalChars = $lineCount * $maxLen
    $positions = @()
    for ($i = 0; $i -lt $totalChars; $i++) {
        $positions += $i
    }
    # Fisher-Yates shuffle
    for ($i = $positions.Count - 1; $i -gt 0; $i--) {
        $j = Get-Random -Minimum 0 -Maximum ($i + 1)
        $temp = $positions[$i]
        $positions[$i] = $positions[$j]
        $positions[$j] = $temp
    }

    $charsPerFrame = [Math]::Max(1, [Math]::Ceiling($totalChars / $Duration))
    $revealedCount = 0

    # Display grid — starts as spaces
    $displayGrid = @()
    for ($r = 0; $r -lt $lineCount; $r++) {
        $row = @()
        for ($c = 0; $c -lt $maxLen; $c++) {
            $row += ' '
        }
        $displayGrid += ,$row
    }

    $sb = [System.Text.StringBuilder]::new($maxLen * $lineCount * 2)

    for ($frame = 0; $frame -lt $Duration; $frame++) {
        # Reveal characters for this frame
        for ($s = 0; $s -lt $charsPerFrame -and $revealedCount -lt $totalChars; $s++) {
            $pos = $positions[$revealedCount]
            $r = [Math]::Floor($pos / $maxLen)
            $c = $pos % $maxLen
            $displayGrid[$r][$c] = $charGrid[$r][$c]
            $revealedCount++
        }

        # Build display string
        [void]$sb.Clear()
        for ($r = 0; $r -lt $lineCount; $r++) {
            if ($r -gt 0) { [void]$sb.AppendLine() }
            for ($c = 0; $c -lt $maxLen; $c++) {
                [void]$sb.Append($displayGrid[$r][$c])
            }
        }

        try {
            if ($frame -gt 0 -and [Console]::CursorTop -ge $lineCount) {
                [Console]::SetCursorPosition(0, [Console]::CursorTop - $lineCount)
            }
            Write-Host $sb.ToString() -NoNewline
        } catch {
            Write-Host $sb.ToString()
        }

        Start-Sleep -Milliseconds 40
    }

    Write-Host ""
    return $CowOutput
}
