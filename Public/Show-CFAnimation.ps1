function Show-CFAnimation {
    <#
    .SYNOPSIS
        Displays cow output with the configured animation mode.
        .DESCRIPTION
        Dispatches to the appropriate animation function based on config.
        Modes: static, talking, typewriter, slide-in, bounce, dissolve,
        fade-in, blink, wiggle, wave, disco, dynamic.
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
            return Invoke-TalkingAnimation -CowOutput $CowOutput -Message $Message -Duration $config.animation.duration
        }
        'typewriter' {
            return Invoke-TypewriterAnimation -CowOutput $CowOutput -Message $Message -Speed $config.animation.speed
        }
        'slide-in' {
            return Invoke-SlideInAnimation -CowOutput $CowOutput -Message $Message -Speed $config.animation.speed
        }
        'bounce' {
            return Invoke-BounceAnimation -CowOutput $CowOutput -Message $Message -Duration $config.animation.duration
        }
        'dissolve' {
            return Invoke-DissolveAnimation -CowOutput $CowOutput -Message $Message -Duration $config.animation.duration
        }
        'fade-in' {
            return Invoke-FadeInAnimation -CowOutput $CowOutput -Message $Message -Duration $config.animation.duration
        }
        'blink' {
            return Invoke-BlinkAnimation -CowOutput $CowOutput -Message $Message -Duration $config.animation.duration -BlinkRate $config.animation.blinkRate
        }
        'wiggle' {
            return Invoke-WiggleAnimation -CowOutput $CowOutput -Message $Message -Duration $config.animation.duration -Amplitude $config.animation.amplitude
        }
        'wave' {
            return Invoke-WaveAnimation -CowOutput $CowOutput -Message $Message -Speed $config.animation.speed
        }
        'disco' {
            return Invoke-DiscoAnimation -CowOutput $CowOutput -Message $Message -Speed $config.animation.speed -Duration $config.animation.duration
        }
        'dynamic' {
            return Invoke-DynamicAnimation -Duration $config.animation.duration -CycleInterval $config.animation.cycleInterval
        }
        default {
            return Invoke-StaticAnimation -CowOutput $CowOutput -Message $Message
        }
    }
}
