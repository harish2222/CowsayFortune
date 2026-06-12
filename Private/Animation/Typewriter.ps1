function Invoke-TypewriterAnimation {
    <#
    .SYNOPSIS
        Animates cow output with typewriter character-by-character display.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(10, 500)]
        [int]$Speed = 50
    )

    $lines = $CowOutput -split "`n"
    foreach ($line in $lines) {
        $chars = $line.ToCharArray()
        $sb = [System.Text.StringBuilder]::new($chars.Length)
        foreach ($char in $chars) {
            Write-Host -NoNewline $char
            [void]$sb.Append($char)
            Start-Sleep -Milliseconds $Speed
        }
        Write-Host ''
    }

    return $CowOutput
}
