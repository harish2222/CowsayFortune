function Show-CFAnimation {
    <#
    .SYNOPSIS
        Displays cow output with the configured animation mode.
    .DESCRIPTION
        Dispatches to the appropriate animation function based on config.
        Modes: static (instant), talking (mouth movement), typewriter (char-by-char).
    .PARAMETER CowOutput
        The rendered cow string to animate.
    .PARAMETER Message
        The original message text (used by some animations).
    .EXAMPLE
        Show-CFAnimation -CowOutput $cow -Message "Hello"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = ''
    )

    $config = Get-CFConfig
    $mode = $config.animation.mode

    switch ($mode) {
        'talking' {
            Invoke-TalkingAnimation -CowOutput $CowOutput -Message $Message -Duration $config.animation.duration
        }
        'typewriter' {
            Invoke-TypewriterAnimation -CowOutput $CowOutput -Message $Message -Speed $config.animation.speed
        }
        default {
            Invoke-StaticAnimation -CowOutput $CowOutput -Message $Message
        }
    }
}
