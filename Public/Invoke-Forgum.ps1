function Invoke-Forgum {
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
    .PARAMETER Lolcat
        Enable rainbow lolcat colorization for this invocation.
        Overrides the lolcat configuration setting.
    .EXAMPLE
        Invoke-Forgum
        Shows a cow with a random fortune.
    .EXAMPLE
        Invoke-Forgum -Lolcat
        Shows a rainbow-colored cow with a random fortune.
    .EXAMPLE
        Invoke-Forgum -Think -CowFile 'tux'
        Shows tux thinking a fortune.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [switch]$Think,

        [ValidateNotNullOrEmpty()]
        [string]$CowFile,

        [string]$Eyes,

        [string]$Tongue,

        [switch]$Lolcat
    )

    $config = Get-CFConfig

    $fortune = Get-Fortune -Database $config.fortune.database

    $cowParams = @{ Text = $fortune }
    if ($CowFile) { $cowParams.CowFile = $CowFile }
    if ($Eyes)    { $cowParams.Eyes    = $Eyes }
    if ($Tongue)  { $cowParams.Tongue  = $Tongue }
    if ($Think)   { $cowParams.Thoughts = 'o' }

    # Determine effective lolcat: explicit switch OR config setting
    $useLolcat = $Lolcat -or $config.lolcat.enabled

    if ($useLolcat) {
        $cowParams.Lolcat = $true
    }

    $cowOutput = Invoke-Cowsay @cowParams

    # Display output
    if ($useLolcat) {
        $animate = $config.lolcat.animate
        # $null = suppresses Show-Lolcat's return value; [Console]::WriteLine handles display
        $null = Show-Lolcat -Text $cowOutput -Animate:$animate
    } else {
        $null = Show-CFAnimation -CowOutput $cowOutput -Message $fortune
    }

    return $cowOutput
}