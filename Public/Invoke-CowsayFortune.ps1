function Invoke-CowsayFortune {
    <#
    .SYNOPSIS
        Combines cowsay + fortune + optional lolcat in one command.
    .DESCRIPTION
        Gets a random fortune, renders it with a cow, optionally applies
        rainbow colorization, and displays with the configured animation.
    .PARAMETER Think
        Use thinking bubble instead of speech bubble.
    .PARAMETER CowFile
        Override the cow file from config.
    .PARAMETER Eyes
        Override the eye characters from config.
    .PARAMETER Tongue
        Override the tongue characters from config.
    .EXAMPLE
        Invoke-CowsayFortune
        Shows a cow with a random fortune.
    .EXAMPLE
        Invoke-CowsayFortune -Think -CowFile 'tux'
        Shows tux thinking a fortune.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [switch]$Think,

        [ValidateNotNullOrEmpty()]
        [string]$CowFile,

        [string]$Eyes,

        [string]$Tongue
    )

    $config = Get-CFConfig

    $fortune = Get-Fortune -Database $config.fortune.database

    $cowParams = @{ Text = $fortune }
    if ($CowFile) { $cowParams.CowFile = $CowFile }
    if ($Eyes)    { $cowParams.Eyes    = $Eyes }
    if ($Tongue)  { $cowParams.Tongue  = $Tongue }
    if ($Think)   { $cowParams.Thoughts = 'o' }

    $cowOutput = Invoke-Cowsay @cowParams

    if ($config.lolcat -and $config.lolcat.enabled) {
        $cowOutput = Format-Lolcat -Text $cowOutput `
            -Frequency $config.lolcat.frequency `
            -Truecolor:$config.lolcat.truecolor
    }

    Show-CFAnimation -CowOutput $cowOutput -Message $fortune
}
