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
        foreach ($char in $line.ToCharArray()) {
            Write-Host -NoNewline $char
            Start-Sleep -Milliseconds $Speed
        }
        Write-Host ''
    }

    return $CowOutput
}
