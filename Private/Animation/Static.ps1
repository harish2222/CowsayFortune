function Invoke-StaticAnimation {
    <#
    .SYNOPSIS
        Displays cow output immediately (no animation).
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = ''
    )

    return $CowOutput
}
