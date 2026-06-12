function Invoke-StaticAnimation {
    <#
    .SYNOPSIS
        Displays cow output immediately (no animation).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = ''
    )

    return $CowOutput
}
